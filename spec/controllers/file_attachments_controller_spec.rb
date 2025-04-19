require "spec_helper"

RSpec.describe FileAttachmentsController do
  describe "GET /file_attachments" do
    before do
      sign_in FactoryBot.create(:superadmin)
    end

    can_index :file_attachments
  end
end
