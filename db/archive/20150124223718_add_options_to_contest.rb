class AddOptionsToContest < ActiveRecord::Migration
  def change
    add_column :contests, :startcode, :string # plain-text start-code
    add_column :contests, :observation, :integer, default: 1 # for observers: public (everyone), protected (groups it is added to even if not competing), private (only if competing)
    add_column :contests, :registration, :integer, default: 0 # open (to all group members), application (by all group members), invitation (to anybody), private (no invites - admin add only)
    # display school affiliation, may require school set to join contest
    # and/or display country (if not displayed, the fields are not copied over)
    add_column :contests, :affiliation, :integer, default: 0

    # may be changed until contest started
    add_column :contest_relations, :school_id, :integer
    add_column :contest_relations, :country_id, :integer

    # admin settings
    add_column :contest_relations, :status, :integer, default: 0 # or DSQ, DNS
    add_column :contest_relations, :extra_time, :integer, default: 0 # seconds

    # sets a window for competing
    # may not start contest until start_time, after start, cannot set start_time after started_at
    # submissions after end_time will not be considered for scoring
    add_column :contest_relations, :start_time, :datetime
    add_column :contest_relations, :end_time, :datetime
  end
end
