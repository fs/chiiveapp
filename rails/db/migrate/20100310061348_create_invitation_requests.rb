class CreateInvitationRequests < ActiveRecord::Migration
  def self.up
    create_table :invitation_requests do |t|
      t.string :name
      t.string :email
      t.datetime :sent_at
      t.datetime :accepted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :invitation_requests
  end
end
