class BasePresenter
  def initialize(object, template)
    @object = object
    @template = template
  end

  def present tag, *fields
    options = fields.extract_options!
    fields.map do |args|
      h.content_tag tag, options do
        args = Array(args)
        field = args.slice!(0)
        result = case field
        when Symbol, String
          self.public_send field, *args
        when Proc
          field.call *args
        else
          raise
        end
      end
    end.reduce(:+)
  end

private

  def self.presents name
    define_method name do
      @object
    end
  end

  def self.present_resource_links
    define_method :edit_link do
      h.link_to 'Edit', h.send("edit_#{@object.class.name.tableize.singularize}_path", @object)
    end

    define_method :destroy_link do
      h.link_to 'Destroy', @object, :method => :delete, :data => { :confirm => 'Are you sure?' }
    end
  end

  def self.present_owner_link
    define_method :linked_owner do
      h.link_to @object.owner.username, @object.owner if @object.owner.present?
    end
  end

  def h
    @template
  end
end
