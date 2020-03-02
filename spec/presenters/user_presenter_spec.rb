require 'spec_helper'

describe UserPresenter do
  it "delegates username" do
    presenter = UserPresenter.new(users(:user))
    expect(presenter.username).to eq(users(:user).username)
  end
end
