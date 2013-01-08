require "spec_helper"

describe AiContestsController do
  describe "routing" do

    it "routes to #index" do
      get("/ai_contests").should route_to("ai_contests#index")
    end

    it "routes to #new" do
      get("/ai_contests/new").should route_to("ai_contests#new")
    end

    it "routes to #show" do
      get("/ai_contests/1").should route_to("ai_contests#show", :id => "1")
    end

    it "routes to #edit" do
      get("/ai_contests/1/edit").should route_to("ai_contests#edit", :id => "1")
    end

    it "routes to #create" do
      post("/ai_contests").should route_to("ai_contests#create")
    end

    it "routes to #update" do
      put("/ai_contests/1").should route_to("ai_contests#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/ai_contests/1").should route_to("ai_contests#destroy", :id => "1")
    end

  end
end
