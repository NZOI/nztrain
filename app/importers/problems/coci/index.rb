module Problems
  module COCI
    module Index
      extend ActiveSupport::Concern
      # 
      # local relative to Rails.root/db/data/downloads/importers/coci
      #
      # [ # index/series format
      #   { # volume format
      #     name: "COCI 2006/2007",
      #     url: "http://...",
      #     contests: [
      #                 {
      #                   name: "Contest #1",
      #                   problem_set_id: 0,
      #                   timestamp: "DateTime",
      #                   tasks: {local: "local.pdf" || nil, url: ...},
      #                   testdata: {local: "local.zip" || nil, url: ...},
      #                   solutions: {file_attachment_id: 0, local: "local.zip" || nil, url: ...},
      #                   results: {url: "url"},
      #                   problems: [
      #                     {
      #                       name: "Modulo",
      #                       problem_id: 0,
      #                       points: 100, # not implemented
      #                       images: ["name1.jpg", "name2.tif", ...]
      #                       tests: [{local: "localsource.extension", model: true, url: "http://...", points: 0, submission_id: nil},...]
      #                     }
      #                   ]
      #                 },
      #                 ...
      #               ]
      #   },
      #   ...
      # ]
      #
      included do
        SOURCE = "http://www.hsin.hr/coci/"
        DATAPATH = File.expand_path("db/data/downloads/importers/coci/",Rails.root)
        INDEXFILE = File.expand_path("index.yaml",DATAPATH)
        CONTEST_RESOURCES = {tasks: "Tasks", testdata: "Test data", solutions: "Solutions", results: "Results"}

        class COCINameMatcher
          def self.series_match node_set
            node_set.find_all { |node| node.text =~ /^(COCI )([[:digit:]]{4})(.)([[:digit:]]{4})$/ }
          end
          def self.contest_match node_set
            node_set.find_all { |node| node.text =~ /^(Contest #[[:digit:]]+|Croatian ([[:alpha:]]+ )+in Informatics)$/i }
          end
          def self.canonicalize_series(title)
            matcher = title.match(/^(COCI )([[:digit:]]{4})(.)([[:digit:]]{4})$/)
            matcher[1] + matcher[2] + "/" + matcher[4]
          end
        end
      end

      def initialize
        @index = nil
      end

      def update # updates the index
        index
        agent = Mechanize.new
        rootpage = agent.get(SOURCE)
        # checkout archive links
        candidate_links = rootpage.links_with(:href => /^(#{SOURCE})?archive\/[[:digit:]]{4}.[[:digit:]]{4}\/?$/) + rootpage.links_with(:text => /^COCI [[:digit:]]{4}.[[:digit:]]{4}$/).uniq { |link| link.href }
        candidate_links.map{|link| [URI.join(rootpage.uri, link.uri), link.text]}.each do |uri, text|
          index_page(agent.get(uri), text)
        end
        index_page(rootpage)
        save
        true
      rescue Mechanize::ResponseCodeError
        false
      end

      def download(vn, cn) # volume/contest number
        agent = Mechanize.new
        agent.pluggable_parser.default = Mechanize::Download
        agent.pluggable_parser.pdf = Mechanize::Download
        contest = self.contest(vn, cn) or return false
        resources = CONTEST_RESOURCES.keys.reject{|r|r==:results}
        resources.reject{|r|r==:solutions}.each do |attr|
          return false if contest[attr].nil? || contest[attr][:url].nil?
        end
        resources.each do |attr|
          next if contest[attr].nil? || contest[attr][:url].nil?
          filepath = "volume-#{vn}/contest-#{vn}/#{File.basename(contest[attr][:url])}"
          fullpath = File.expand_path(filepath, DATAPATH)
          agent.get(contest[attr][:url]).save!(fullpath) # download file
          contest[attr][:local] = filepath
        end
        save
        true
      end

      def downloaded?(vn, cn)
        contest = self.contest(vn, cn) or return false
        %i[tasks testdata].each do |attr|
          return false if contest[attr].nil? || contest[attr][:local].nil?
          return false unless File.exists?(File.expand_path(contest[attr][:local], DATAPATH))
        end
        true
      end

      def contest(vn, cn)
        return nil if vn.nil? || vn == ""
        return nil if cn.nil? || cn == ""
        vn = vn.to_i
        cn = cn.to_i
        return nil unless vn < index.size || vn < 0
        return nil unless cn < index[vn][:contests].size || cn < 0
        contest = index[vn][:contests][cn]
      end

      def contests(vn)
        return [] if vn.nil? || vn == ""
        vn = vn.to_i
        return [] unless vn < index.size || vn < 0
        index[vn][:contests]
      end

      def index_page(page, title = nil)
        title = page.root.xpath(".//*[not(ancestor::a) and series_match(.)]", COCINameMatcher).first.text if title.nil?
        series = {name: COCINameMatcher.canonicalize_series(title), url: (page.canonical_uri || page.uri).to_s, contests: []}
        page.root.xpath(".//td").each do |td|
          contest = td.xpath(".//*[contest_match(.)]", COCINameMatcher).first
          next if contest.nil?
          contest = {name: contest.text.titleize}
          CONTEST_RESOURCES.each do |attr, label|
            link = td.xpath(".//a[. = '#{label}']").first
            next if link.nil?
            contest[attr] = {url: URI.join(page.uri, link.attributes['href'].value).to_s}
          end
          series[:contests] << contest
        end
        # merge series into index...
        existing_series = index.map{ |series| series[:name] }
        series_index = existing_series.index(series[:name]) || existing_series.size
        merge_series!(index[series_index] ||= {}, series)
      end

      # list from file
      def list
        index
      end

      def load
        if !File.exists?(INDEXFILE)
          @index = []
        else
          @index = Psych.safe_load(File.read(INDEXFILE), [Symbol], %i[name local url contests problem_set_id timestamp tasks testdata solutions results problems problem_id points images tests submission_id model language_id file_attachment_id])
        end
        true
      end

      def index
        self.load if @index.nil?
        @index
      end

      def store
        
      end

      def save
        File.open(INDEXFILE, "w") {|f| Psych.dump(index, f) }
        true
      end

      def set_problem_set_id(vid, cid, id)
        contest = self.contest(vid, cid) or return false
        if id.nil? || id == ""
          contest[:problem_set_id] = nil
        else
          contest[:problem_set_id] = id if ProblemSet.find(id)
        end
        save
      end

      def set_problem_id(vid, cid, pid, id)
        contest = self.contest(vid, cid) or return false
        problems = (contest[:problems] || [])
        return false if pid == "" or pid.nil?
        pid = pid.to_i
        return false unless pid < problems.size || pid < 0
        if id.nil? || id == ""
          contest[:problems][pid][:problem_id] = nil
        else
          contest[:problems][pid][:problem_id] = id if Problem.find(id)
        end
        save
      end

      private
      def merge_series!(series, updated)
        series.merge!(updated.slice(:name, :url)) # top-level merge
        series[:contests] ||= []

        (updated[:contests] || []).each do |contest|
          existing_contests = series[:contests].map{|contest| contest[:name] }
          contest_index = existing_contests.index(contest[:name]) || existing_contests.size

          (series[:contests][contest_index] ||= {}).merge!(contest.slice(:name))
          CONTEST_RESOURCES.keys.each do |attr|
            (series[:contests][contest_index][attr] ||= {}).merge!(contest[attr] || {})
          end
        end
        series
      end
    end
  end
end
