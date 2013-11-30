class Submission
  class Data
    def initialize(data)
      @data = data || {}
    end

    def data
      @data
    end
  end
  class JudgeData < Data
    class Meta < Data
      def disp float
        return sprintf "%.3f", float if float < 10
        return sprintf "%.2f", float if float < 100
        return sprintf "%.1f", float if float < 1000
        sprintf "%.0f", float
      end

      def memory
        return "" if data.empty?
        mem = (data['cg-mem'] || data['max-rss'])
        unit = "kB"
        mem/=1000 and unit="MB" if mem > 1000
        mem/=1000 and unit="GB" if mem > 1000
        "#{disp(mem)} #{unit}"
      end

      def time
        return "" if data['time'].nil?
        "#{disp(data['time'])} seconds"
      end

      def walltime
        sprintf "%.3f seconds", data['time-wall']
      end

      def message
        data['message']
      end

      def status
        data['status']
      end

      def result
        case status
        when 'SG'; :signal
        when 'TO'; message =~ /wall/ ? :walltime : :timeout 
        when 'RE'; :runtime
        end
      end
    end

    module Runnable
      def output
        data['output']
      end

      def log
        data['log']
      end

      def errored?
        meta.nil? || meta.status!='OK'
      end

      def meta
        Meta.new(data['meta'])
      end
    end

    class Compilation < Data
      include Runnable

      def evalerrored?
        errored? && data['stat'] == 2
      end

      def command
        data['command']
      end

      def status
        return :pending if data.nil?
        return :success if !errored?
        return meta.result if data['stat'] == 1
        return :error
      end

      def judgement
        case status
        when :timeout; "Time Limit Exceeded"
        when :walltime; "Time Limit Exceeded (Wall)"
        when :runtime; "Runtime Error"
        when :signal; "Fatal Signal"
        when :pending; "Pending"
        when :success; "Success"
        when :error; "Errored"
        end
      end
    end

    class Evaluation < Data
      include Runnable
      def result
        return :correct if evaluation == 1
        return :wrong if evaluation == 0
        return :pending if evaluation.nil?
        return :partial
      end

      def evaluation
        data['evaluation']
      end

      def message
        return "" if data.nil? || data['message'].nil?
        data['message']
      end

      def info
        return "" if data.empty?
        [data['box'],*data['meta'].map{|k,v|"#{k}:#{v}"},data['log']].join("\n")
      end
    end

    class CaseData < Data
      include Runnable

      def judgement
        case status
        when :correct; "Correct!"
        when :wrong; "Wrong Answer"
        when :partial; sprintf("Partial Score %.2f/1.00", evaluation)
        when :error; "Evaluator Errored"
        when :timeout; "Time Limit Exceeded"
        when :walltime; "Time Limit Exceeded (Wall)"
        when :runtime; "Runtime Error"
        when :signal; "Fatal Signal"
        when :pending; "Pending"
        end + ( evaluator.message.empty? ? "" : " - " + evaluator.message)
      end

      def status
        return :pending if data.nil?
        return :error if evalerrored?
        return meta.result if data['stat'] == 1
        evaluator.result
      end

      def message
        evaluator.meta.message
      end

      def evaluator
        @evaluator ||= Evaluation.new(data['evaluator'])
      end

      def evalerrored?
        data['stat'] == 2 or (!errored? && evaluator.errored?)
      end

      def evaluation
        evaluator.evaluation
      end

      def time
        return "" if data['time'].nil?
        "#{meta.disp(data['time'])} seconds"
      end

      def killed?
        meta.data['killed'] == 1
      end
    end

    module Evaluable
      def status
        return :pending if data.nil? || data['status'].nil?
        case data['status']
        when 0;
          return :correct if evaluation == 1
          return :wrong if evaluation == 0
          return :partial
        when 1; :pending
        when 2; :error
        end
      end

      def evaluation
        data['evaluation']
      end

      def score
        data['score']
      end

      def judgement
        case status
        when :pending; "Pending"
        when :error; "Errored"
        else; print_score
        end
      end

      def print_score
        sprintf "%.2f", score
      end
    end

    class SetData < Data
      include Enumerable
      include Evaluable

      attr_accessor :id

      def initialize(data, cases, caseset)
        super(data)
        self.data.delete(:status) if !self.data.has_key?('cases') || self.data['cases'].size != cases.size || (self.data['cases']&cases).size < cases.size # missing test cases
        @test_cases = caseset.slice(*cases)
      end

      def test_cases
        @test_cases
      end

      def print_score
        "+"+super
      end
    end

    def initialize(log, test_sets, test_cases)

      super(log.nil? ? {} : JSON.parse(log))
      @_test_sets = test_sets
      @_test_cases = test_cases
    end

    def errored?
      data.has_key?('error')
    end

    def completed?
      !errored?
    end

    def compiled?
      data.has_key?('compile')
    end

    def compilation
      @compilation ||= Compilation.new(data['compile'])
    end

    def test_sets
      @test_sets ||= Hash[@_test_sets.map { |id, cases| [id, SetData.new(test_set_data[id.to_s], cases, test_cases)] }]
    end

    def test_cases
      @test_cases ||= Hash[@_test_cases.map { |id| [id, CaseData.new(test_case_data[id.to_s])] }]
    end
    
    include Evaluable

    private
    def test_case_data
      data['test_cases'] || {}
    end

    def test_set_data
      data['test_sets'] || {}
    end

    def print_score
      score.to_i
    end
  end
end
