require "spec_helper"

describe AiContestsController do
  before { pending }
  describe "routing" do

    it "routes to #index" do
      expect(get("/ai_contests")).to route_to("ai_contests#index")
    end

    it "routes to #new" do
      expect(get("/ai_contests/new")).to route_to("ai_contests#new")
    end

    it "routes to #show" do
      expect(get("/ai_contests/1")).to route_to("ai_contests#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/ai_contests/1/edit")).to route_to("ai_contests#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/ai_contests")).to route_to("ai_contests#create")
    end

    it "routes to #update" do
      expect(put("/ai_contests/1")).to route_to("ai_contests#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/ai_contests/1")).to route_to("ai_contests#destroy", :id => "1")
    end

  end
end
