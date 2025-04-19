class ApplicationPresenter < StrongPresenter::Presenter
  private

  def self.present_owner_link
    define_method :linked_owner do
      h.link_to object.owner.username, object.owner if object.owner.present?
    end
  end

  def self.present_resource_links
    define_method :edit_link do
      h.link_to "Edit", h.send("edit_#{object.class.name.tableize.singularize}_path", object)
    end

    define_method :destroy_link do
      h.link_to "Destroy", object, method: :delete, data: {confirm: "Are you sure?"}
    end
  end
end
