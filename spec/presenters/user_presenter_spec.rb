require 'spec_helper'

describe UserPresenter do
  it "delegates username" do
    presenter = UserPresenter.new(users(:user), view)
    presenter.username.should == users(:user).username
  end
end
