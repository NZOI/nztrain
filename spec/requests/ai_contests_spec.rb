require 'spec_helper'

describe "AiContests" do
  describe "GET /ai_contests" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get ai_contests_path
      response.status.should be(200)
    end
  end
end
