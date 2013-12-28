module Problems
  module COCI
    class PDFImporter
      class TextStructureReceiver
        attr_accessor :state

        delegate :save_graphics_state, :restore_graphics_state, :concatenate_matrix, :begin_text_object, :end_text_object, :set_character_spacing, :set_horizontal_text_scaling, :set_text_font_and_size, :font_size, :set_text_leading, :set_text_rendering_mode, :set_text_rise, :set_word_spacing, :move_text_position, :move_text_position_and_set_leading, :set_text_matrix_and_text_line_matrix, :move_to_start_of_next_line, to: :state

        def page=(page)
          @state = PDF::Reader::PageState.new(page)
          rotation = (page.page_object[:Rotate] || 0)%360
          @rotation_matrix = case rotation
          when 90; [0,-1,1,0,0,0]
          when 180; [-1,0,0,-1,0,0]
          when 270; [0,1,-1,0,0,0]
          else; [1,0,0,1,0,0]
          end
          @content = []
          @characters = []
          @mediabox = page.objects.deref(page.attributes[:MediaBox])
          # note after rotation, we will often have -ve coordinates
          @mediabox = [trsf(@rotation_matrix, @mediabox[0,2]), trsf(@rotation_matrix, @mediabox[2,2])].transpose.map(&:sort).transpose.flatten
        end

        def rotated_coordinates(coord)
          trsf(@rotation_matrix, coord)
        end

        def show_text(text)
          text_width = 0
          glyphs = state.current_font.unpack(text)
          utf8_text = glyphs.map do |glyph_code|
            utf8_chars = state.current_font.to_utf8(glyph_code)
            glyph_width = state.current_font.glyph_width(glyph_code) / 1000.0
            th = 1
            scaled_glyph_width = glyph_width * state.font_size * th
            text_width += scaled_glyph_width
            utf8_chars
          end.join
          x, y = rotated_coordinates(state.trm_transform(0,0))
          return_text(utf8_text, state, [x, y], text_width)
        end
        def width
          @mediabox[2] - @mediabox[0]
        end
        def height
          @mediabox[3] - @mediabox[1]
        end
        def abs2rel pos
          [(pos[0]-@mediabox[0])/width, (pos[1]-@mediabox[1])/height]
        end
        def show_text_with_positioning(array)
          show_text(array.select{|el|el.is_a?(String)}.join)
        end
        alias_method :move_to_next_line_and_show_text, :show_text
        alias_method :set_spacing_next_line_show_text, :show_text

        def return_text(current_text, state, abspos, textwidth)
          puts "TEXT@#{sprintf("[%.2f,%.2f]", *abs2rel(abspos))}: #{current_text}"
        end

        def trsf(mat, coord)
          [mat[0]*coord[0]+mat[2]*coord[1]+mat[4],mat[1]*coord[0]+mat[3]*coord[1]+mat[5]]
        end
      end

      class SummaryReceiver < TextStructureReceiver
        LABELS = {name: 'task', memory_limit: 'memory', time_limit: 'time limit'}
        attr_accessor :current_label, :labelx, :labelindex, :summary, :assigned_last
        def initialize
          self.labelindex = 0
          self.summary = []
          reset_stored_text
          super
        end
        def reset_stored_text
          @stored_text = {text: "", x: 0.0, y: nil, fontname: nil}
        end
        def assign_next(label, string)
          value = string.strip
          remainder = ""
          case label
          when :name
            return 0 if value.empty?
            value = value.mb_chars.titleize.to_s
          when :memory_limit
            return 0 unless value =~ /([[:digit:]]+(\.[[:digit:]]+)?) ?((m|k)?)b/i
            remainder = string.slice($~.end(0), string.length)
            value = $~[1].to_f
            case $~[3]
            when *%w[m M];
            when *%w[k K]; value /= 1024
            else value /= 1024*1024
            end
          when :time_limit
            return 0 unless value =~ /([[:digit:]]+(\.[[:digit:]]+)?) ?((sec(onds?)?|min(utes?))?)/i
            remainder = string.slice($~.end(0), string.length)
            value = $~[1].to_f
            value *= 60 if $~[3] =~ /\Amin/
          end
          self.summary[labelindex] ||= {}
          self.summary[labelindex][label] = value
          self.labelindex += 1
          assigned = 1
          if !remainder.strip.empty?
            assigned += assign_next(label, remainder)
          end
          assigned
        end
        def rewind_last(n = 1)
          self.labelindex -= n
        end
        def return_text(current_text, state, abspos, text_width)
          position_start = abspos
          position_end = abspos.dup
          position_end[0] += text_width # doesn't account for vertical text

          fontname = state.current_font.try(:font_descriptor).try(:font_name)
          reset_stored_text if position_start[1] != @stored_text[:y] || fontname.nil? || fontname != @stored_text[:fontname] || (@stored_text[:x]-position_start[0]).abs > (state.current_font.glyph_width(32) / 1000.0 * state.font_size) * 0.5
          current_text = @stored_text[:text] + current_text # based on positioning coordinates, we join up separated text objects (if x difference < half a space width)
          relx = abs2rel(position_start)[0]
          if relx < 0.3
            self.current_label = self.labelx = nil if !labelx.nil? && relx <= labelx - 0.03
            LABELS.each do |attribute, label|
              if (summary.empty? || !summary[0].has_key?(attribute)) && current_text =~ /#{label}/i
                self.current_label = attribute
                self.labelx = relx
                self.labelindex = 0
                self.assigned_last = 0
                return
              end
            end
          end
          if !self.current_label.nil?
            self.labelx = relx
            rewind_last(self.assigned_last) if self.assigned_last > 0 && !@stored_text[:text].empty?
            self.assigned_last = assign_next(current_label, current_text)
          end
          @stored_text.merge!(x: position_end[0], y: position_end[1], fontname: fontname, text: current_text)
        end
      end

      # the tags to apply for different styles
      class HTMLMarkdown
        attr_accessor :state
        def initialize
          self.state = {pre: false, endp: false}
        end
        def bold(before, after)
          before != after ? "<#{'/' if before}strong>" : ''
        end
        def italic(before, after)
          before != after ? "<#{'/' if before}em>" : ''
        end
        def monospace(before, after)
          before != after ? "<#{'/' if before}code>" : ''
        end
        def pre(before, after)
          state[:pre] = after
          before != after ? "<#{'/' if before}pre>#{"\n\n" if before}" : ''
        end
        def escape(text)
          # text.gsub(/[\\`*_{}\[\]\(\)#+-\.!]/,"\\\0") # markdown
          text = text.gsub(/</,"&lt;").gsub(/>/,"&gt;").gsub(/&/,"&amp;") # escape html
          text = text.gsub(/[\\\$]/,'\\\\\0') # escape markdown backslash and mathjax $ delimiter (Loofah scrubber)
          #"„‟“”".bytes # stylized single and double quotes
          #=> [226, 128, 158, 226, 128, 159, 226, 128, 156, 226, 128, 157]
          text.gsub(/[„‟]/,"'").gsub(/[“”]/,'"')
        end
        def heading(text)
          "## #{escape(text)}"
        end
        def list_item(before, after)
          before != after ? "<#{'/' if before}li>" : ''
        end
        def list(before, after)
          before != after ? "<#{'/' if before}ul>#{"\n\n" if before}" : ''
        end
        def image(source)
          "<img src=\"#{source}\">"
        end
        def paragraph(text)
          end_paragraph + (state[:pre] ? "#{text}\n" : "#{text}".tap{ state[:endp] = true })
        end
        def append_paragraph(text)
          text
        end
        def append_next_paragraph
          state[:endp] = false
        end
        def end_paragraph
          state[:endp] ? "\n\n".tap{ state[:endp] = false } : ""
        end
      end

      class StatementReceiver < TextStructureReceiver
        attr_accessor :name_array, :current_name, :name_index, :full_text, :statements # ordered
        attr_accessor :marked_content, :mark_options, :section_text_start, :paragraph, :paragraph_style
        attr_accessor :markup, :sample_section, :no_marked_content, :page_text
        attr_reader :page
        attr_accessor :images
        def initialize(name_array, markup = HTMLMarkdown.new)
          self.name_array = name_array
          self.name_index = 0
          self.statements = []
          self.marked_content = []
          self.mark_options = []
          self.section_text_start = []
          self.full_text = ""
          self.markup = markup
          self.images = []
          self.page_text = ""
          reset_paragraph
          reset_statement
          super()
        end
        def reset_paragraph
          extra = {}
          extra[:prevx] = paragraph[:x] if paragraph && paragraph.has_key?(:x)
          self.paragraph = {text: "", plain: "", count: 0, bold_count: 0, bold: false, italic: false, monospace: false, list_item: false, monospace_count: 0, images: []}.merge(extra)
        end
        def page=(page)
          if self.no_marked_content
            create_paragraph
          end
          end_page()
          self.page_text = ""
          self.current_name = nil
          @page = page
          super(page)
        end
        def reset_statement
          self.paragraph_style = {pre: false, list: false}
          self.sample_section = false
          self.no_marked_content = false
          @unmarkedend = nil
        end
        def begin_marked_content_with_pl(tag, options)
          self.no_marked_content = false
          if tag == :Span && options.has_key?(:MCID)
            tag = :P
            options[:tag] = :Span
          end
          marked_content.push tag
          mark_options.push options
          section_text_start.push(full_text.length)
        end
        def begin_marked_content
          begin_marked_content_with_pl(nil, {})
        end
        def end_marked_content
          tag = marked_content.pop
          options = mark_options.pop
          starti = section_text_start.pop
          section_text = full_text.slice(starti, full_text.length - starti)
          case tag
          when :P # paragraph
            if (!paragraph[:plain].strip.empty?) || !paragraph[:images].empty?
              create_paragraph(options)
            end
          when :Artifact # ended header/footer
            #puts "Artifact: #{section_text}"
            if self.current_name.nil?
              self.current_name = detect_task(section_text)
              if !current_name.nil? # set task for statement
                set_task()
              end
            end
          end
          #puts "TEXT at end of #{tag}: #{section_text}"
        end
        def create_paragraph(options = {})
          parastyle = {list: paragraph[:list_item], pre: false}
          end_paragraph()
          skip = false
          paragraph_images = []
          if !paragraph[:plain].empty? && paragraph[:monospace_count] == paragraph[:count] # preformatted
            parastyle[:pre] = true
            paragraph[:text] = markup.escape(paragraph[:plain])
            skip = sample_section
          elsif !paragraph[:plain].empty? && paragraph[:bold_count]+1 >= paragraph[:count] && paragraph[:plain].length <= 60 # heading
            skip = self.sample_section = !!(paragraph[:plain] =~ /\bsample\b/i)
            paragraph[:text] = markup.heading(paragraph[:plain])
            if self.no_marked_content # remove fake headings
              if paragraph[:plain].strip =~ /(Author:[[:alnum:] ]|[[:alnum:]]+ round[[:alnum:] ,]+2013)/
                paragraph[:text] = ""
              end
            end
          else
            paragraph_images = paragraph[:images]
          end
          if !within?(:Artifact) && !skip # end of paragraph
            %i[list pre].each do |attr|
              append_statement(markup.send(attr, paragraph_style[attr], paragraph_style[attr] = parastyle[attr]))
            end
            if options[:tag] == :Span
              append_statement(markup.append_paragraph(paragraph[:text]))
              markup.append_next_paragraph
            else
              append_statement(markup.paragraph(paragraph[:text]))
            end
            self.images += paragraph_images
            self.statements[current_name][:images] += paragraph_images if !current_name.nil?
          end
          reset_paragraph
        end
        def set_task
          reset_statement() if self.name_index != current_name
          self.name_index = current_name
          self.statements[current_name] ||= {}
          self.statements[current_name][:name] ||= name_array[current_name]
          self.statements[current_name][:statement] ||= ""
          self.statements[current_name][:pages] ||= []
          self.statements[current_name][:pages] |= [page.number]
          self.statements[current_name][:images] ||= []
        end
        def detect_task(text)
          # normalize for any accents
          candidate_tasks = name_array.drop(name_index)
          silence_warnings do # warning: regexp match /.../n against to UTF-8 string
            #                 decompose accent, remove non-ASCII (accents)
            text = text.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').to_s
            candidate_tasks = candidate_tasks.map{|name| name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').to_s }
          end
          candidate_tasks.each_with_index do |candidate, index|
            return name_index + index if text =~ /(?<=[^[:word:]]|^)Task[[:space:]]+#{candidate}(?=[^[:word:]]|$)/i
          end
          candidate_tasks.each_with_index do |candidate, index|
            return name_index + index if text =~ /(?<=[^[:word:]]|^)#{candidate}(?=[^[:word:]]|$)/i
          end
          nil
        end
        def within?(tag)
          marked_content.include?(tag)
        end
        def append_statement(text)
          return if current_name.nil?
          self.statements[current_name][:statement] += text
        end
        def append_text(text)
          self.full_text << text
          self.page_text << text
        end
        def append_paragraph(text, state)
          if self.paragraph[:text].empty?
            paragraph[:x] = state.trm_transform(0,0).first
          end
          style = {list_item: paragraph[:list_item], bold: false, italic: false, monospace: false}
          fontdes = state.current_font.font_descriptor
          if fontdes
            style[:bold] = (fontdes.font_weight > 500 || !!("#{fontdes.font_name}" =~ /bold/i))
            style[:italic] = (fontdes.italic_angle > 0 || !!("#{fontdes.font_name}" =~ /italic/i))
            style[:monospace] = !!(fontdes.font_name =~ /courier ?new/i)
          end
          self.paragraph[:count] += text.length
          self.paragraph[:bold_count] += text.length if style[:bold]
          self.paragraph[:monospace_count] += text.length if style[:monospace]
          if !style[:monospace] && text.length == 1 && 
            (57344...63744).include?(text.codepoints.first) && # private use area
            self.paragraph[:plain].empty? && !paragraph[:prevx].nil? && paragraph[:prevx]+2 < paragraph[:x]
            # this is a bullet point (probably)
            style[:list_item] = true
            text = ''
            paragraph[:x] = paragraph[:prevx] # save x before list started
          end
          style.each do |attr, after|
            self.paragraph[:text] << markup.send(attr, paragraph[attr], paragraph[attr] = style[attr])
          end
          self.paragraph[:text] << markup.escape(text)
          self.paragraph[:plain] << text
        end
        def process_image(label, state)
          mat = page.xobjects[label].hash[:Matrix]
          box = page.xobjects[label].hash[:BBox]
          if box
            corners = [[0,1],[0,3],[2,1],[2,3]].map{|i,j| state.ctm_transform(*trsf(mat,box.values_at(i,j)))}.transpose
            global_bbox = [corners[0].min, corners[1].min, corners[0].max-corners[0].min, corners[1].max-corners[1].min]
          else
            global_bbox = state.ctm_transform(0,0) + [state.ctm_transform(1,1),state.ctm_transform(0,0)].transpose.map{|b,a|b-a}
          end
          image_filename = PDF::ExtractImages::Extractor.xobjectfilename(page.number, label, page.xobjects[label])
          # text, imageinfo
          return markup.image(image_filename), [page.number, label, global_bbox]
        end
        def append_image_to_paragraph(label, state)
          text, imageinfo = process_image(label, state)
          self.paragraph[:text] << text
          self.paragraph[:images] << imageinfo
        end
        def end_paragraph
          %i[monospace italic bold list_item].each { |attr| self.paragraph[:text] << markup.send(attr, paragraph[attr], false) }
        end
        def end_page
          append_statement(markup.pre(paragraph_style[:pre], paragraph_style[:pre] = false))
        end
        def return_text(text, state, abspos, textwidth)
          append_text(text)
          # potential text to add to statement
          if !within?(:Artifact) && within?(:P)
            append_paragraph(text, state) 
          elsif marked_content.empty? # not in anything!
            if self.current_name.nil?
              self.current_name = detect_task(page_text)
              if !current_name.nil? # set task for statement
                set_task()
                self.no_marked_content = true # very likely there are no paragraph marks to help us :(
              end
            elsif self.no_marked_content
              append_paragraph(text, state)
              @unmarkedend = abspos
              @unmarkedend[0] += textwidth # a bit of a munge here (doesn't take page rotation... into account)
            end
          end
        end
        def move_text_position(dx, dy)
          super
          x, y = rotated_coordinates(state.trm_transform(0,0)) # actual coordinates
          if self.no_marked_content && @unmarkedend # are we moving very far away?
            charwidth = (state.current_font.glyph_width(32) / 1000.0 * state.font_size) # of a SPACE
            if ((x-@unmarkedend[0])/6)**2 + (y-@unmarkedend[1])**2 > (charwidth)**2 # we are moving somewhere else?!?!
              if abs2rel([x,y])[0] < 0.3 && abs2rel(@unmarkedend)[0] > 0.8 # probably end of line in the same paragraph
                # do nothing
              else # probably starting a new paragraph
                create_paragraph
              end
            end
          end
        end
        def extract_statements
          end_page()
          statements
        end
        def invoke_xobject(label)
          if !within?(:Artifact)
            case page.xobjects[label].hash[:Subtype]
            when :Image, :Form
              if within?(:P)
                append_image_to_paragraph(label, state)
              elsif !current_name.nil?
                text, imageinfo = process_image(label, state)
                append_statement(text)
                self.statements[current_name][:images] << imageinfo
              end
              # form = PDF::Reader::FormXObject.new(page, page.xobjects[label])
              # for :Form, extract to svg or take snapshot
            end
          end
        end
      end

      attr_accessor :pdf_path, :reader

      def initialize(pdf_path)
        self.pdf_path = pdf_path
        self.reader = PDF::Reader.new(pdf_path)
      end

      # get array of problem data
      def extract
        summary = extract_summary
        statements = extract_statements(summary.map{ |problem| problem[:name] })
        images = extract_images(statements.map{|statement| statement[:images]}.flatten(1))
        #puts reader.pages.first.text
        problem_data = summary.zip(statements).map{|summary, statement| summary.merge(statement)}.map do |data|
          data[:images] = images.slice(*data[:images].map{|pg, name, bbox|[pg,name]}) # get subset of images needed by problem
          data
        end
        problem_data
      end

      private
      def extract_summary
        #reader.page(1).walk(TextStructureReceiver.new)
        summary_receiver = SummaryReceiver.new
        reader.page(1).walk(summary_receiver)
        #puts summary_receiver.summary.inspect
        summary_receiver.summary
      end

      def extract_statements(problemlist)
        statement_receiver = StatementReceiver.new(problemlist)
        reader.pages.drop(1).each do |page|
          page.walk(statement_receiver)
        end
        #puts statement_receiver.extract_statements.inspect
        statement_receiver.extract_statements
      end

      def extract_images(imagelist)
        extractor = PDF::ExtractImages::Extractor.new(pdf_path, reader)
        extracted_images = extractor.extract_images(imagelist)
        #puts extracted_images.inspect
        extracted_images
      end
    end
  end
end

