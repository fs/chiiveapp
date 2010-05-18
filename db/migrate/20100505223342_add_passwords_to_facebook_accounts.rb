class AddPasswordsToFacebookAccounts < ActiveRecord::Migration
  def self.up
    @users = User.find(:all, :conditions => 'crypted_password IS NULL')
    @users.each do |user|
      user.password = UUIDTools::UUID.timestamp_create().to_s
      user.save(false)
    end
  end

  def self.down
  end
end
