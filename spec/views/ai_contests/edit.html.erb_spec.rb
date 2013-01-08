require 'spec_helper'

describe "ai_contests/edit" do
  before(:each) do
    @ai_contest = assign(:ai_contest, stub_model(AiContest,
      :title => "MyString",
      :owner_id => "",
      :sample_ai => "MyText",
      :statement => "MyText",
      :judge => "MyString"
    ))
  end

  it "renders the edit ai_contest form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => ai_contests_path(@ai_contest), :method => "post" do
      assert_select "input#ai_contest_title", :name => "ai_contest[title]"
      assert_select "input#ai_contest_owner_id", :name => "ai_contest[owner_id]"
      assert_select "textarea#ai_contest_sample_ai", :name => "ai_contest[sample_ai]"
      assert_select "textarea#ai_contest_statement", :name => "ai_contest[statement]"
      assert_select "input#ai_contest_judge", :name => "ai_contest[judge]"
    end
  end
end
