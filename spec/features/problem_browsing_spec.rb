require "spec_helper"

feature "Problem browsing" do
  let(:user) { FactoryBot.create(:superadmin) }
  let!(:problem) { FactoryBot.create(:problem) }

  scenario "Admin browses and view problems" do
    login_as user, scope: :user

    visit "/problems"

    headers = find(".main_table > thead > tr").all("th").map(&:text)
    rows = find(".main_table > tbody").all("tr").map { |r| r.all("td").map(&:text) }
    expect(headers).to eq(["", "Name", "Input", "Output", "Memory Limt", "Time Limit", "Owner", "Progress", "", ""])
    expect(rows.length).to eq(Problem.count)

    expect(rows[0]).to eq(["", problem.name, problem.input, problem.output, "1 MB", "1.0 s", "System", "", "Edit", "Destroy"])
  end
end
