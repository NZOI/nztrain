module FixturesSpecHelper
  @@table_names = [:users, :problems, :test_sets]

  def self.initialize
    @@users = { :user => Factory.create(:user), :admin => Factory.create(:admin), :superadmin => Factory.create(:superadmin) }
    @@problems = { :problem => Factory.create(:problem) }
    @@test_sets = { :test_set => Factory.create(:test_set, :problem => @@problems[:problem]) }
  end

  def self.destroy
    @@table_names.each do |table|
      (class_variable_get "@@#{table}".to_sym).each { |k,v| v.destroy }
    end
  end

  @@table_names.each do |table|
    class_variable_set "@@#{table}".to_sym, {}
    define_method table do |key|
      (self.class.class_variable_get "@@#{table}".to_sym)[key]
    end
  end

end

