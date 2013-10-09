class BasePresenter
  def initialize(object, template)
    @object = object
    @template = template
  end

  def present tags, *fields
    options = fields.extract_options!
    if tags.class != Array
      options = {tags => options}
      tags = Array(tags)
    end
    fields.map do |fieldargs|
      present_field tags, fieldargs, options
    end.reduce(:+)
  end

private

  def present_field tags, fieldargs, options
    h.content_tag tags[0], options[tags[0]] do
      tags = tags.drop(1)
      if tags.empty?
        args = Array(fieldargs)
        field = args.slice!(0)
        result = case field
        when Symbol, String
          self.public_send field, *args
        when Proc
          field.call *args
        else
          raise
        end
      else
        present_field tags, fieldargs, options
      end
    end
  end

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
