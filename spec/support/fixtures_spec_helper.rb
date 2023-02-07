module FixturesSpecHelper
  @@table_names = [:users, :problems, :test_sets]

  def self.initialize
    @@users = {
      :user => FactoryBot.create(:user),
      :organiser => FactoryBot.create(:organiser),
      :admin => FactoryBot.create(:admin),
      :superadmin => FactoryBot.create(:superadmin)
    }
    @@problems = { :problem => FactoryBot.create(:problem) }
    @@test_sets = { :test_set => FactoryBot.create(:test_set, :problem => @@problems[:problem]) }
  end

  def self.destroy
    @@table_names.each do |table|
      (class_variable_get "@@#{table}".to_sym).each { |k,v|
        v.clear_association_cache # touching already destroyed association object causes `touch': can not touch on a new record object (ActiveRecord::ActiveRecordError)
        v.destroy
      }
    end
  end

  @@table_names.each do |table|
    class_variable_set "@@#{table}".to_sym, {}
    define_method table do |key|
      (self.class.send :class_variable_get, "@@#{table}".to_sym)[key]
    end
  end

end

