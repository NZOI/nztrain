module Problems

  TestCaseImportOptions = HashWithIndifferentAccess.new
  TestCaseImporters = HashWithIndifferentAccess.new
  {
    :testcase => [TestCaseImporter, "Native Format"],
    :flatcase => [FlatCaseImporter, "Flat Directory"]
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

end
