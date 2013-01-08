require 'spec_helper'

describe "ai_contests/show" do
  before(:each) do
    @ai_contest = assign(:ai_contest, stub_model(AiContest,
      :title => "Title",
      :owner_id => "",
      :sample_ai => "MyText",
      :statement => "MyText",
      :judge => "Judge"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Title/)
    rendered.should match(//)
    rendered.should match(/MyText/)
    rendered.should match(/MyText/)
    rendered.should match(/Judge/)
  end
end
