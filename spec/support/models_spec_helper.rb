module ModelsSpecHelper
  # List of [testset, evaluation] pairs
  def make_eval_string data
    test_sets_object = "{" + data.map { |testset, evaluation| "\"#{testset.id}\":{\"evaluation\":#{evaluation}}" }.join(",") + "}"
    '{"test_cases":{}, "test_sets":' + test_sets_object + "}"
  end
end
