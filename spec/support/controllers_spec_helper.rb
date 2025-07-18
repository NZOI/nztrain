module ControllersSpecHelper
  def self.included(base)
    base.extend(ClassMethods)
    base.send :before, :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end
  end

  def process_hash hash
    if hash.instance_of?(Proc)
      return instance_eval(&hash)
    elsif hash.instance_of?(Hash)
      hash.each do |key, value|
        hash[key] = process_hash value
      end
    end
    hash || {}
  end

  def subject_object(resource)
    if respond_to?(resource)
      send(resource)
    else
      instance_variable_get("@#{resource}")
    end
  end

  module ClassMethods
    def _process_options options
      options[:attributes] ||= {}
      options[:resource_path] ||= "#{options[:resource_name]}_path"
      options[:resources_path] ||= "#{options[:resources_name]}_path"
      options[:class_name] ||= options[:resource_name].to_s.camelize
      options
    end

    def process_options resource, options
      options = options.symbolize_keys
      options[:resource_name] ||= resource.to_sym
      options[:resources_name] ||= options[:resource_name].to_s.pluralize.to_sym
      _process_options options
    end

    def process_plural_options resource, options
      options = options.symbolize_keys
      options[:resources_name] ||= resource
      options[:resource_name] ||= options[:resources_name].to_s.singularize.to_sym
      _process_options options
    end

    def can_index resource, options = {}
      options = process_plural_options resource, {action: :index}.merge(options)
      it "can #{options[:action]} #{resource}" do
        get options[:action], params: process_hash(options[:params])
        expect(response).to be_success
        collection = assigns(options[:resources_name])
        expect(collection.is_a?(ActiveRecord::Relation) || collection.is_a?(Array)).to be true
      end
    end

    def can_browse resource, options = {}
      can_index resource, options.merge(action: :browse)
    end

    def can_manage resource, options = {}
      can_show resource, options
      can_update resource, options
      can_destroy resource, options
    end

    def can_show resource, options = {}
      options = process_options resource, options

      it "can show #{resource}" do
        object = subject_object(resource)
        get :show, params: {id: object.to_param}
        expect(response).to be_success
      end
    end

    def can_update resource, options = {}
      options = process_options resource, options

      it "can edit #{resource}" do
        object = subject_object(resource)
        get :edit, params: {id: object.to_param}
        expect(response).to be_success
        assigns(options[:resource_name]).instance_of?(object.class)
      end

      it "can update #{resource}" do
        object = subject_object(resource)
        put :update, params: {:id => object.to_param, options[:resource_name] => object.attributes.symbolize_keys.merge(options[:attributes])}
        expect(response).to redirect_to send "#{options[:resource_name]}_path", assigns(options[:resource_name])
        expect(assigns(options[:resource_name])).to have_attributes(options[:attributes])
      end
    end

    def can_create resource, options = {}
      options = process_options resource, options

      it "can get new #{resource}" do
        get :new
        expect(response).to be_success
      end

      it "can create #{resource}" do
        expect do
          post :create, params: {options[:resource_name] => options[:attributes]}
        end.to change { (Kernel.const_get options[:class_name]).count }.by(1)
        expect(response).to redirect_to send "#{options[:resource_name]}_path", assigns(options[:resource_name])
        expect(assigns(options[:resource_name])).to have_attributes(options[:attributes])
      end
    end

    def can_destroy resource, options = {}
      options = process_options resource, options

      it "can destroy #{resource}" do
        object = subject_object(resource)
        expect do
          delete :destroy, params: {id: object.to_param}
        end.to change { object.class.count }
          .by(-1)
        expect(response).to be_redirect
      end
    end
  end

  # Instance methodss
  RSpec::Matchers.define :have_attributes do |expected|
    match do |actual|
      matching = true
      expected.each do |key, value|
        matching &&= if actual[key].instance_of?(ActiveSupport::TimeWithZone) && value.instance_of?(String)
          (actual[key] == Time.zone.parse(value))
        else
          (actual[key] == value)
        end
      end
      matching
    end
    failure_message do |actual|
      message = "expected attributes of object to match hash:\n"
      expected.each do |key, value|
        matching = if actual[key].instance_of?(ActiveSupport::TimeWithZone) && value.instance_of?(String)
          (actual[key] == (val = Time.zone.parse(value)))
        else
          (actual[key] == (val = value))
        end
        message << "#{key}: expected #{val}, got #{actual[key]}\n" unless matching
      end
      message
    end
    failure_message_when_negated do |actual|
      "expected not completely matching attributes #{expected}, got #{actual.attributes}"
    end
    description do
      "check that attributes of an object completely matches a hash"
    end
  end
end
