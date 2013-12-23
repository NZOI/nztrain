require 'spec_helper'

module Problems
  describe TestCaseImporter do
    class DeferredZip
      def initialize(&zipblock)
        if block_given?
          @zipblock = zipblock
        else
          @zipblock = ->(z) {}
        end
      end
      def with_zip
        Dir.mktmpdir do |dir|
          zippath = File.expand_path('zipfile.zip',dir)
          Zip::File.open(zippath, Zip::File::CREATE) { |zipfile| @zipblock.call(zipfile) }
          yield zippath
        end
      end
    end
    def make_test_case_directories(zipfile)
      %w[inputs outputs].each { |dir| zipfile.dir.mkdir(dir) }
    end
    describe 'import' do
      it 'imports no cases or sets' do
        problem = Problem.create(name: "New Problem for import")
        DeferredZip.new do |zipfile|
          make_test_case_directories(zipfile)
          zipfile.file.open('specification.yaml',"w") { |f| f.write({'test_sets' => []}.to_yaml) }
        end.with_zip do |zippath|
          TestCaseImporter.import(problem, zippath, :extension => '.zip', :merge => false)
        end
        expect(problem.test_cases).to be_empty
        expect(problem.test_sets).to be_empty
      end

      it 'imports tests' do
        problem = Problem.create(name: "New Problem for import")
        num_cases = 2
        DeferredZip.new do |zipfile|
          make_test_case_directories(zipfile)
          (1..num_cases).each do |i|
            %w[in out].each { |io| zipfile.file.open("#{io}puts/test#{i}.txt", "w") { |f| f.puts "#{io}put" } }
          end
          zipfile.file.open('specification.yaml',"w") do |f|
            f.write({'test_sets' => {'s1' => {'points' => 2, 'test_cases' => %w[test1]}, 's2' => {'test_cases' => %w[test1 test2]}}}.to_yaml)
          end
        end.with_zip do |zippath|
          TestCaseImporter.import(problem, zippath, :extension => '.zip', :merge => false)
        end
        expect(problem.test_cases.count).to eq num_cases
        expect(problem.test_sets.count).to eq 2
        expect(problem.test_sets.first.test_cases.count).to eq 1
        expect(problem.test_cases.first.name).to eq 'test1'
        expect(problem.test_sets.first.points).to eq 2
        expect(problem.test_sets[1].test_cases.size).to eq 2
      end

      describe 'merging tests' do
        before do
          @problem = Problem.create(name: "New Problem for import")
          @problem.test_cases << TestCase.new(name: "test1", input: "original", output: "original")
          @problem.test_sets << TestSet.new(name: "s1", test_cases: @problem.test_cases.where(name: 'test1'))
          @num_cases = 3
          DeferredZip.new do |zipfile|
            make_test_case_directories(zipfile)
            (1..@num_cases).each do |i|
              %w[in out].each { |io| zipfile.file.open("#{io}puts/test#{i}.txt", "w") { |f| f.puts "#{io}put" } }
            end
            zipfile.file.open('specification.yaml',"w") do |f|
              f.write({'test_sets' => {'s1' => {'points' => 2, 'test_cases' => %w[test1 test3]}, 's2' => {'test_cases' => %w[test1 test2]}}}.to_yaml)
            end
          end.with_zip do |zippath|
            TestCaseImporter.import(@problem, zippath, :extension => '.zip', :merge => true)
          end
        end
        it 'has expected tests' do
          expect(@problem.test_cases.count).to eq @num_cases
          expect(@problem.test_sets.count).to eq 2
          expect(@problem.test_sets.first.test_cases.count).to eq 2
          expect(@problem.test_cases.first.name).to eq 'test1'
          expect(@problem.test_sets.first.test_cases.pluck(:name)).to include('test3')
        end

        it 'has new input' do
          expect(@problem.test_cases.first.input.strip).to eq "input"
        end

        it 'has shared test case' do
          @problem.test_sets.each do |set|
            expect(set.test_cases.first).to eq @problem.test_cases.first
          end
        end
      end
    end
  end
end
