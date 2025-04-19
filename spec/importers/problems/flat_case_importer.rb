require "spec_helper"

module Problems
  describe FlatCaseImporter do
    class DeferredZip
      def initialize(&zipblock)
        @zipblock = zipblock || ->(z) {}
      end

      def with_zip
        Dir.mktmpdir do |dir|
          zippath = File.expand_path("zipfile.zip", dir)
          Zip::File.open(zippath, Zip::File::CREATE) { |zipfile| @zipblock.call(zipfile) }
          yield zippath
        end
      end
    end
    describe "import" do
      it "imports empty zip" do
        problem = Problem.create(name: "New Problem for import")
        DeferredZip.new.with_zip do |zippath|
          FlatCaseImporter.import(problem, zippath, extension: ".zip", merge: false)
        end
        expect(problem.test_cases).to be_empty
      end

      it "imports tests" do
        problem = Problem.create(name: "New Problem for import")
        num_cases = 2
        DeferredZip.new do |zipfile|
          (1..num_cases).each do |i|
            %w[in out].each { |io| zipfile.file.open("test#{i}.#{io}", "w") { |f| f.puts "#{io}put" } }
          end
        end.with_zip do |zippath|
          FlatCaseImporter.import(problem, zippath, extension: ".zip", merge: false)
        end
        expect(problem.test_cases.count).to eq num_cases
        expect(problem.test_sets.count).to eq num_cases
        expect(problem.test_sets.first.test_cases.count).to eq 1
        expect(problem.test_cases.first.name).to eq "test1"
      end

      describe "merging tests" do
        before do
          @problem = Problem.create(name: "New Problem for import")
          @problem.test_cases << TestCase.new(name: "test1", input: "original", output: "original")
          @problem.test_sets << TestSet.new(name: "test1", test_cases: @problem.test_cases.where(name: "test1"))
          @num_cases = 2
          DeferredZip.new do |zipfile|
            (1..@num_cases).each do |i|
              %w[in out].each { |io| zipfile.file.open("test#{i}.#{io}", "w") { |f| f.puts "#{io}put" } }
            end
          end.with_zip do |zippath|
            FlatCaseImporter.import(@problem, zippath, extension: ".zip", merge: true)
          end
        end
        it "has expected tests" do
          expect(@problem.test_cases.count).to eq @num_cases
          expect(@problem.test_sets.count).to eq @num_cases
          expect(@problem.test_sets.first.test_cases.count).to eq 1
          expect(@problem.test_cases.first.name).to eq "test1"
        end

        it "has new input" do
          expect(@problem.test_cases.first.input.strip).to eq "input"
        end
      end
    end
  end
end
