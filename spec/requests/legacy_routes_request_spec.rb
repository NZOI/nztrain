require "spec_helper"

RSpec.describe "Legacy routes maintained for compat" do
  describe "Forem removal / replacement" do
    ["/forum", "/forum/", "/forum/news/topics/welcome-to-forem"].each do |path|
      describe path do
        it "renders the forum deprecated page" do
          get path
          expect(response).to render_template("pages/forum")
        end
      end
    end
  end
end
