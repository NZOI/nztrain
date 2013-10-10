module StrongPresenter
  module CollectionHelper
    # Enumerates collection to call permit on each presenter
    def permit *fields
      self.each { |presenter| presenter.permit *fields }
      self
    end

    # Enumerates collection to call permit! on each presenter
    def permit!
      self.each { |presenter| presenter.permit! }
      self
    end

    # Checks if fields are visible on first presenter in collection
    def filter *args
      self.first.filter *args
    end
  end

  class Base
    # Constructs the presenter, taking 1 argument for the object being wrapped
    def initialize(object)
      @object = object
    end

    # Wraps a model using a new instance of the presenter, and returns the instance. For example:
    #
    #   user_presenter = UserPresenter.wrap :user
    #
    # A block can also be passed to use the presenter. For example:
    #
    #   <% UserPresenter.wrap @user do |user_presenter| %>
    #     Username: <%= user_presenter.username %>
    #   <% end %>
    #
    def self.wrap *objects
      presenter = self.new *objects
      yield presenter if block_given?
      presenter
    end

    # Wraps each model in a collection with the presenter. A block can also be 
    # passed to use each presenter immediately. For example:
    #
    #   <ul>
    #     <% UserPresenter.wrap_each @users do |user_presenter| %>
    #       <li><%= user_presenter.username %></li>
    #     <% end %>
    #   </ul>
    #
    def self.wrap_each collection
      collection.map! do |object|
        self.wrap object do |presenter|
          yield presenter if block_given?
        end
      end
      collection.send :extend, StrongPresenter::CollectionHelper
      collection
    end

    # Performs mass presentation - if it is allowed, subject to `permit`. To permit all without checking, call `permit!` first.
    #
    # Presents and returns the result of each field in the argument list. If a block is given, then each result
    # is passed to the block. Each field is presented by calling the method on the presenter.
    #
    #   user_presenter.presents :username, :email # returns [user_presenter.username, user_presenter.email]
    #
    # Or with two arguments, the name of the field is passed first:
    #
    #   <ul>
    #     <% user_presenter.presents :username, :email, :address do |field, value| %>
    #       <li><%= field.capitalize %>: <% value %></li>     
    #     <% end %>
    #   </ul>
    #
    # If only the presented value is desired, use `each`:
    #
    #   <% user_presenter.presents(:username, :email).each do |value| %>
    #     <td><%= value %></td>
    #   <% end %>
    #
    # A field can have arguments in an array:
    #
    #   user_presenter.presents :username, [:notifications, :unread] # returns [user_presenter.username, user_presenter.notifications(:unread)]
    #
    # Notice that this interface allows you to concisely put authorization logic in the controller, with a dumb view layer:
    #
    #   # app/controllers/users_controller.rb
    #   class UsersController < ApplicationController
    #     def visible_params
    #       @visible_params ||= begin
    #         field = [:username]
    #         field << :email if can? :read_email, @user
    #         field << :edit_link if can? :edit, @user
    #       end
    #     end
    #     def show
    #       @users_presenter = UserPresenter.wrap_each(User.all).permit!
    #     end
    #   end
    #
    #   # app/views/users/show.html.erb
    #   <table>
    #     <tr>
    #       <% visible_params.each do |field| %>
    #         <th><%= field %></th>
    #       <% end %>
    #     </tr>
    #     <% @users_presenter.each do |user_presenter| %>
    #       <tr>
    #         <% user_presenter.presents(*visible_params).each do |value| %>
    #           <td><%= value %></td>
    #         <% end %>
    #       </tr>
    #     <% end %>
    #   </table>
    #
    def presents *fields, &block
      process_fields(fields).map do |args|
        value = self.public_send *args
        yield args[0], value if block_given?
        value
      end
    end

    # Checks which fields are visible according to what is permitted. An array is returned.
    # The array can be converted to labels using `to_labels`
    #
    def filter *fields
      fields = process_fields(fields).map(&:first)
      presenter_class = self.class
      (class << fields; self; end).class_eval do
        define_method :to_labels do
          presenter_class.label fields
        end
      end
      fields
    end

    # Pass a hash to set field labels { field => label}
    # Pass an array to retrieve labels for field symbols. If no label is set, the return
    # value is the humanized field by default.
    #
    def self.label fields
      @labels ||= {}
      if fields.class == Hash
        @labels.merge!(fields)
      else
        labels = Array(fields).map { |field| @labels[field] || field.to_s.humanize }
        return labels if fields.respond_to? :map
        labels.first
      end
    end

    # Sets fields which will be permitted. May be invoked multiple times.
    #
    def permit *fields
      self.permitted_attributes.merge fields if permitted_attributes != :all
      self
    end

    # Permits all fields
    #
    def permit!
      @permitted_attributes = :all
      self
    end

  protected
    def permitted_attributes
      @permitted_attributes ||= Set.new
    end

  private
    def process_fields fields
      fields.map! do |field|
        field = Array(field)
        field[0] = field[0].to_sym
        field
      end
      fields.select! { |field| permitted_attributes.include? field[0] } if permitted_attributes != :all
      fields
    end

    # Sets the model presented by the class
    #
    def self.presents name
      define_method name do
        @object
      end
    end

    # Permits all fields in the presenter for mass presentation
    #
    def self.permit!
      define_method(:permitted_attributes){:all}
    end

    def object
      @object
    end

    # Access to view helpers
    #
    def h
      @helper ||= Helper.new
    end

    class Helper < ActionView::Base
      include Rails.application.routes.url_helpers

      def method_missing method, *args, &block
        if ApplicationController.helpers.respond_to? method
          ApplicationController.helpers.public_send method, *args, &block
        else
          super
        end
      end
      def respond_to? method, include_all = false
        ApplicationController.helpers.respond_to?(method, include_all) or super
      end
    end
  end
end
