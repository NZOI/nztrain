require 'spec_helper'

describe "ai_contests/index" do
  before(:each) do
    assign(:ai_contests, [
      stub_model(AiContest,
        :title => "Title",
        :owner_id => "",
        :sample_ai => "MyText",
        :statement => "MyText",
        :judge => "Judge"
      ),
      stub_model(AiContest,
        :title => "Title",
        :owner_id => "",
        :sample_ai => "MyText",
        :statement => "MyText",
        :judge => "Judge"
      )
    ])
  end

  it "renders a list of ai_contests" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Judge".to_s, :count => 2
  end
end
