module FixturesSpecHelper
  @@table_names = [:users, :problems, :test_sets]

  def self.initialize
    @@users = {
      :user => FactoryGirl.create(:user),
      :admin => FactoryGirl.create(:admin),
      :superadmin => FactoryGirl.create(:superadmin),
      :organiser => FactoryGirl.create(:organiser)
    }
    @@problems = { :problem => FactoryGirl.create(:problem) }
    @@test_sets = { :test_set => FactoryGirl.create(:test_set, :problem => @@problems[:problem]) }
  end

  def self.destroy
    @@table_names.each do |table|
      (class_variable_get "@@#{table}".to_sym).each { |k,v| v.destroy }
    end
  end

  @@table_names.each do |table|
    class_variable_set "@@#{table}".to_sym, {}
    define_method table do |key|
      (self.class.send :class_variable_get, "@@#{table}".to_sym)[key]
    end
  end

end

