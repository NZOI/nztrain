module Problems
  TestCaseImportOptions = HashWithIndifferentAccess.new
  TestCaseImporters = HashWithIndifferentAccess.new
  {
    testcase: [TestCaseImporter, "Native Format"],
    flatcase: [FlatCaseImporter, "Flat Directory"]
  }.each do |key, (importer, description)|
    TestCaseImporters[key] = importer
    TestCaseImportOptions[description] = key
  end

  ImportOptions = TestCaseImportOptions.dup
  Importers = TestCaseImporters.dup

  {
  }.each do |key, (importer, description)|
    Importers[key] = importer
    ImportOptions[description] = key
  end

  def self.pdf n = 1
    imp = COCI::PDFImporter.new(File.expand_path("contest#{n}_tasks.pdf", Rails.root))
    problems = imp.extract
    puts problems[0].inspect
    byebug
    nil
  end

  def self.test
    importer = COCI::Importer.new
    # updates index of contests
    # indexer.update

    # downloads contest data
    puts "downloaded?(0, 0): #{importer.downloaded?(0, 0)}"
    importer.download(0, 0) unless importer.downloaded?(0, 0)

    # parses contest statement, images and test case zip files into temporary directory

    # creates problem set if necessary

    #
    # for each problem:

    # import problem statement

    # import problem test cases

    # import some pdf pages into files section

    # import test submissions
  end
end
