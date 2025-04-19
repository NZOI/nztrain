module Problems
  class TestCaseExporter < BaseExporter
    include RenderAnywhere
    # Problems::TestCaseExporter.export(Problem.find(1), '/home/ronald/sample/sample.zip')
    def export(path, options = {})
      problem = subject
      inpath = File.expand_path("inputs", path)
      outpath = File.expand_path("outputs", path)
      dir.mkdir(inpath)
      dir.mkdir(outpath)
      # export the test cases
      problem.test_cases.each do |kase|
        file.open(File.expand_path(kase.name + ".txt", inpath), "w") do |f|
          f.write kase.input
          tempfiles << f
        end
        file.open(File.expand_path(kase.name + ".txt", outpath), "w") do |f|
          f.write kase.output
          tempfiles << f
        end
      end
      # export the test sets
      file.open(File.expand_path("specification.yaml", path), "w") do |f|
        f.write render template: "problems/specification", format: "yaml", locals: {problem: problem}
        tempfiles << f
      end
      path
    end

    def around_export(path, options)
      super
    end
  end
end
