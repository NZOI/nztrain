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
      #     issues: [
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
        IDENTIFIER = "COCI"
        DATAPATH = File.expand_path("db/data/downloads/importers/coci/",Rails.root)
        CONTEST_RESOURCES = {tasks: "Tasks", testdata: "Test data", solutions: "Solutions", results: "Results"}

        class COCINameMatcher
          def self.series_match node_set
            node_set.find_all { |node| node.text =~ /^(COCI )([[:digit:]]{4})(.)([[:digit:]]{4})$/ }
          end
          def self.issue_match node_set
            node_set.find_all { |node| node.text =~ /^(Contest #[[:digit:]]+|Croatian ([[:alpha:]]+ )+in Informatics)$/i }
          end
          def self.canonicalize_series(title)
            matcher = title.match(/^(COCI )([[:digit:]]{4})(.)([[:digit:]]{4})$/)
            matcher[1] + matcher[2] + "/" + matcher[4]
          end
        end
      end

      attr_reader :problem_series

      def initialize(problem_series)
        @problem_series = problem_series
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

      def download(vn, cn) # volume/issue number
        agent = Mechanize.new
        agent.pluggable_parser.default = Mechanize::Download
        agent.pluggable_parser.pdf = Mechanize::Download
        issue = self.issue(vn, cn) or return false
        resources = CONTEST_RESOURCES.keys.reject{|r|r==:results}
        resources.reject{|r|r==:solutions}.each do |attr|
          return false if issue[attr].nil? || issue[attr][:url].nil?
        end
        resources.each do |attr|
          next if issue[attr].nil? || issue[attr][:url].nil?
          filepath = "volume-#{vn}/issue-#{cn}/#{File.basename(issue[attr][:url])}"
          fullpath = File.expand_path(filepath, DATAPATH)
          agent.get(issue[attr][:url]).save!(fullpath) # download file
          issue[attr][:local] = filepath
        end
        save
        true
      end

      def downloaded?(vn, cn)
        issue = self.issue(vn, cn) or return false
        %i[tasks testdata].each do |attr|
          return false if issue[attr].nil? || issue[attr][:local].nil?
          return false unless File.exists?(File.expand_path(issue[attr][:local], DATAPATH))
        end
        true
      end

      def volume(vn)
        return nil if vn.blank?
        vn = vn.to_i
        return nil unless vn < index.size || vn < 0
        index[vn]
      end

      def contest(vn, cn)
        issue(vn, cn)
      end

      def contests(vn)
        issues(vn)
      end

      def issue(vn, cn)
        return nil if vn.blank?
        return nil if cn.blank?
        vn = vn.to_i
        cn = cn.to_i
        return nil unless vn < index.size || vn < 0
        return nil unless cn < index[vn][:issues].size || cn < 0
        issue = index[vn][:issues][cn]
      end

      def issues(vn)
        return [] if vn.nil? || vn == ""
        vn = vn.to_i
        return [] unless vn < index.size || vn < 0
        index[vn][:issues]
      end

      def index_page(page, title = nil)
        if title.nil?
          years = page.links_with(:href => /^http:\/\/www.timeanddate.com\/.*(\?|&)year=([[:digit:]]*)(&|$)/).map{ |link| link.href.match(/(\?|&)year=([[:digit:]]*)(&|$)/)[2].to_i }
          if years.size > 2 && years.min+1 == years.max
            title = "COCI #{years.min}/#{years.max}"
          else
            title = page.root.xpath(".//*[not(ancestor::a) and series_match(.)]", COCINameMatcher).first.text
          end
        end
        series = {name: COCINameMatcher.canonicalize_series(title), url: (page.canonical_uri || page.uri).to_s, issues: []}
        page.root.xpath(".//td").each do |td|
          issue = td.xpath(".//*[issue_match(.)]", COCINameMatcher).first
          next if issue.nil?
          issue = {name: issue.text.titleize}
          CONTEST_RESOURCES.each do |attr, label|
            link = td.xpath(".//a[. = '#{label}']").first
            next if link.nil?
            issue[attr] = {url: URI.join(page.uri, link.attributes['href'].value).to_s}
          end
          series[:issues] << issue
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
        @index = problem_series.index
        true
      end

      def index
        self.load if @index.nil?
        @index
      end

      def store
        
      end

      def save
        problem_series.index = index
        problem_series.save
        true
      end

      def set_problem_set_id(vid, cid, id)
        issue = self.issue(vid, cid) or return false
        if id.blank?
          issue[:problem_set_id] = nil
        else
          issue[:problem_set_id] = id if ProblemSet.find(id)
        end
        save
      end

      def set_problem_id(vid, cid, pid, id)
        issue = self.issue(vid, cid) or return false
        problems = (issue[:problems] || [])
        return false if pid == "" or pid.nil?
        pid = pid.to_i
        return false unless pid < problems.size || pid < 0
        if id.blank?
          issue[:problems][pid][:problem_id] = nil
        else
          issue[:problems][pid][:problem_id] = id if Problem.find(id)
        end
        save
      end

      private
      def merge_series!(series, updated)
        series.merge!(updated.slice(:name, :url)) # top-level merge
        series[:issues] ||= []

        (updated[:issues] || []).each do |issue|
          existing_issues = series[:issues].map{|issue| issue[:name] }
          issue_index = existing_issues.index(issue[:name]) || existing_issues.size

          (series[:issues][issue_index] ||= {}).merge!(issue.slice(:name))
          CONTEST_RESOURCES.keys.each do |attr|
            (series[:issues][issue_index][attr] ||= {}).merge!(issue[attr] || {})
          end
        end
        series
      end
    end
  end
end
