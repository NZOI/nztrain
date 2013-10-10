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
    def visible? *args, &block
      self.first.visible? *args, &block
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
    # If the block takes one argument, the presented value is passed:
    #
    #   <% user_presenter.presents :username, :email do |value| %>
    #     <td><%= value %></td>
    #   <% end %>
    #
    # Or with two arguments, the name of the field is passed first:
    #
    #   <ul>
    #     <% user_presenter.presents :username, :email, :address do |field, value| %>
    #       <li><%= field.capitalize %>: <% value %></li>     
    #     <% end %>
    #   </ul>
    #
    # A field can have arguments in an array:
    #
    #   user_presenter.presents :username, [:notifications, :unread] # returns [user_presenter.username, user_presenter.notifications(:unread)]
    #
    # Each field can have a field name associated (becoming the first argument passed to block instead of the field method name):
    #
    #   user_presenter.presents {"Username" => :username}, {"Email" => :email}, "Address" => :address, "Phone number" => :phone
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
    #       @users_presenter = UserPresenter.present_each(User.all).permit!
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
    #         <% user_presenter.presents *visible_params do |value| %>
    #           <td><%= value %></td>
    #         <% end %>
    #       </tr>
    #     <% end %>
    #   </table>
    #
    def presents *fieldsplat, &block
      process_fieldsplat(fieldsplat).map do |args|
        value = self.public_send *args.drop(1)
        if block_given?
          if block.arity == 1
            yield value
          else
            yield args[0], value
          end
        end
        value
      end
    end

    # Checks which fields are visible according to what is permitted. Does the same thing as
    # `presents`, but never calls the method to present each field. Instead, it just returns the
    # heading name of each field that is visible.
    def visible? *fieldsplat, &block
      process_fieldsplat(fieldsplat).map do |args|
        if block_given?
          if block.arity == 1
            yield args[0]
          else
            yield args[0], args[1]
          end
        end
        args[0]
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
    def process_fieldsplat fieldsplat
      fields = [];
      fieldsplat.each do |field| # convert everything to arrays
        if field.class == Hash
          fields += field.map { |key, value| [key] + Array(value) }
        else
          fields << [Array(field).first] + Array(field)
        end
      end
      fields.select! { |field| permitted_attributes.include? Array(field)[1].to_sym } if permitted_attributes != :all
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
