module Problems
  class COCITaskPDFImporter
    class TextStructureReceiver
      attr_accessor :state, :current_text

      delegate :save_graphics_state, :restore_graphics_state, :concatenate_matrix, :begin_text_object, :end_text_object, :set_character_spacing, :set_horizontal_text_scaling, :set_text_font_and_size, :font_size, :set_text_leading, :set_text_rendering_mode, :set_text_rise, :set_word_spacing, :move_text_position, :move_text_position_and_set_leading, :set_text_matrix_and_text_line_matrix, :move_to_start_of_next_line, to: :state

      def page=(page)
        @state = PDF::Reader::PageState.new(page)
        @content = []
        @characters = []
        @mediabox = page.objects.deref(page.attributes[:MediaBox])
      end
      def show_text(text)
        glyphs = state.current_font.unpack(text)
        text = glyphs.map { |glyph_code| state.current_font.to_utf8(glyph_code) }.join
        current_text << text
        @position_start = state.trm_transform(0,0) if @position_start.nil?
      end
      def width
        @mediabox[2]
      end
      def height
        @mediabox[3]
      end
      def show_text_with_positioning(array)
        show_text(array.select{|el|el.is_a?(String)}.join)
      end
      alias_method :move_to_next_line_and_show_text, :show_text
      alias_method :set_spacing_next_line_show_text, :show_text
      def begin_text_object
        self.current_text = ""
        @position_start = nil
        state.begin_text_object
      end
      def end_text_object
        return_text(current_text, state, @position_start[0]/width, @position_start[1]/height)
        state.end_text_object
      end
      def return_text(current_text, state, relx, rely)
        puts "TEXTOBJ: @#{sprintf("[%.2f,%.2f]", relx, rely)}: #{current_text}"
      end
    end

    class SummaryReceiver < TextStructureReceiver
      LABELS = {name: 'task', memory_limit: 'memory limit', time_limit: 'time limit'}
      attr_accessor :current_label, :labelx, :labelindex, :summary
      def initialize
        self.labelindex = 0
        self.summary = []
        super
      end
      def assign_next(label, string)
        value = string.strip
        case label
        when :name
          return if value.empty?
        when :memory_limit
          return unless value =~ /\A([[:digit:]]+(\.[[:digit:]]+)?) ?((m|k)?)b\z/i
          value = $~[1].to_f
          case $~[3]
          when *%w[m M];
          when *%w[k K]; value /= 1024
          else value /= 1024*1024
          end
        when :time_limit
          return unless value =~ /\A([[:digit:]]+(\.[[:digit:]]+)?) ?((sec(onds?)?|min(utes?))?\z)/i
          value = $~[1].to_f
          value *= 60 if $~[3] =~ /\Amin/
        end
        self.summary[labelindex] ||= {}
        self.summary[labelindex][label] = value
        self.labelindex += 1
      end
      def return_text(current_text, state, relx, rely)
        if relx < 0.3
          self.current_label = self.labelx = nil if !labelx.nil? && relx <= labelx
          LABELS.each do |attribute, label|
            if (summary.empty? || !summary[0].has_key?(attribute)) && current_text =~ /#{label}/i
              self.current_label = attribute
              self.labelx = relx
              self.labelindex = 0
              return
            end
          end
        end
        if !self.current_label.nil?
          self.labelx = relx
          assign_next(current_label, current_text)
        end
      end
    end

    # the tags to apply for different styles
    class HTMLMarkdown
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
        before != after ? "<#{'/' if before}pre>#{"\n\n" if before}" : ''
      end
      def escape(text)
        # text.gsub(/[\\`*_{}\[\]\(\)#+-\.!]/,"\\\0") # markdown
        text = text.gsub(/</,"&lt;").gsub(/>/,"&gt;").gsub(/&/,"&amp;")
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
    end

    class StatementReceiver < TextStructureReceiver
      attr_accessor :name_array, :current_name, :name_index, :full_text, :statements # ordered
      attr_accessor :marked_content, :mark_options, :section_text_start, :paragraph, :paragraph_style
      attr_accessor :markup, :sample_section
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
        end_page()
        self.current_name = nil
        @page = page
        super(page)
      end
      def reset_statement
        self.paragraph_style = {pre: false, list: false}
        self.sample_section = false
      end
      def begin_marked_content_with_pl(tag, options)
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
            parastyle = {list: paragraph[:list_item], pre: false}
            end_paragraph()
            skip = false
            paragraph_images = []
            if !paragraph[:plain].empty? && paragraph[:monospace_count] == paragraph[:count] # preformatted
              parastyle[:pre] = true
              paragraph[:text] = markup.escape(paragraph[:plain])
              skip = sample_section
            elsif !paragraph[:plain].empty? && paragraph[:bold_count] == paragraph[:count] && paragraph[:plain].length <= 60 # heading
              skip = self.sample_section = !!(paragraph[:plain] =~ /\bsample\b/i)
              paragraph[:text] = markup.heading(paragraph[:plain])
            else
              paragraph_images = paragraph[:images]
            end
            if !within?(:Artifact) && !skip # end of paragraph
              %i[list pre].each do |attr|
                append_statement(markup.send(attr, paragraph_style[attr], paragraph_style[attr] = parastyle[attr]))
              end
              append_statement("#{paragraph[:text]}\n")
              self.images += paragraph_images
              append_statement("\n") if !parastyle[:pre]
              self.statements[current_name][:images] += paragraph_images if !current_name.nil?
            end
          end
          reset_paragraph
        when :Artifact # ended header/footer
          #puts "Artifact: #{section_text}"
          if self.current_name.nil?
            self.current_name = detect_task(section_text)
            if !current_name.nil? # set task for statement
              reset_statement() if self.name_index != current_name
              self.name_index = current_name
              self.statements[current_name] ||= {}
              self.statements[current_name][:name] ||= name_array[current_name]
              self.statements[current_name][:statement] ||= ""
              self.statements[current_name][:pages] ||= []
              self.statements[current_name][:pages] |= [page.number]
              self.statements[current_name][:images] ||= []
            end
          end
        end
        #puts "TEXT at end of #{tag}: #{section_text}"
      end
      def detect_task(text)
        candidate_tasks = name_array.drop(name_index)
        candidate_tasks.each_with_index do |candidate, index|
          return name_index + index if text =~ /(?<=[^[:word:]]|^)Task[[:space:]]+#{candidate}(?=[^[:word:]]|$)/i
        end
        candidate_tasks.each_with_index do |candidate, index|
          return name_index + index if text =~ /(?<=[^[:word:]]|^)#{candidate}(?=[^[:word:]]|$)/i
        end
      end
      def within?(tag)
        marked_content.include?(tag)
      end
      def append_statement(text)
        return if current_name.nil?
        self.statements[current_name][:statement] += text
      end
      def append_text(text)
        self.full_text << text # text within current marked content section
      end
      def append_paragraph(text, state)
        if self.paragraph[:text].empty?
          paragraph[:x] = state.trm_transform(0,0).first
        end
        style = {list_item: paragraph[:list_item], bold: false, italic: false, monospace: false}
        fontdes = state.current_font.font_descriptor
        if fontdes
          style[:bold] = (fontdes.font_weight > 500 || !!("#{fontdes.font_family}" =~ /bold/i))
          style[:italic] = (fontdes.italic_angle > 0 || !!("#{fontdes.font_family}" =~ /italic/i))
          style[:monospace] = !!(fontdes.font_name =~ /courier new/i)
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
      def append_image(label, state)
        mat = page.xobjects[label].hash[:Matrix]
        box = page.xobjects[label].hash[:BBox]
        if box
          corners = [[0,1],[0,3],[2,1],[2,3]].map{|i,j| state.ctm_transform(*trsf(mat,box.values_at(i,j)))}.transpose
          global_bbox = [corners[0].min, corners[1].min, corners[0].max-corners[0].min, corners[1].max-corners[1].min]
        else
          global_bbox = state.ctm_transform(0,0) + [state.ctm_transform(1,1),state.ctm_transform(0,0)].transpose.map{|b,a|b-a}
        end
        self.paragraph[:text] << markup.image("fileattachmentroot/#{label}.extension")
        self.paragraph[:images] << [page.number, label, global_bbox]
      end
      def end_paragraph
        %i[monospace italic bold list_item].each { |attr| self.paragraph[:text] << markup.send(attr, paragraph[attr], false) }
      end
      def end_page
        append_statement(markup.pre(paragraph_style[:pre], paragraph_style[:pre] = false))
      end
      def return_text(text, state, relx, rely)
        append_text(text)
        # potential text to add to statement
        append_paragraph(text, state) if !within?(:Artifact) && within?(:P)
      end
      def extract_statements
        end_page()
        statements
      end
      def trsf(mat, coord)
        [mat[0]*coord[0]+mat[2]*coord[1]+mat[4],mat[1]*coord[0]+mat[3]*coord[1]+mat[5]]
      end
      def invoke_xobject(label)
        case page.xobjects[label].hash[:Subtype]
        when :Image
          append_image(label, state) if !within?(:Artifact) && within?(:P)
        when :Form
          # crop(217.16,408.16,180,53) -> 397,460
          # state
          append_image(label, state) if !within?(:Artifact) && within?(:P)
          # form = PDF::Reader::FormXObject.new(page, page.xobjects[label])
          # extract to svg or take snapshot
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
      puts reader.pages.size
      puts reader.pages.first.number
      summary = extract_summary
      statements = extract_statements(summary.map{ |problem| problem[:name] })
      images = extract_images(statements.map{|statement| statement[:images]}.flatten(1))
      #puts reader.pages.first.text
      #reader.page(5).xobjects.values.first.unfiltered_data # image
      ['asdf']
    end

    private
    def extract_summary
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

