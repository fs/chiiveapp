# The name of your application
set :application, "qamio"

# Repository type
default_run_options[:pty] = true
set :scm, :git
ssh_options[:forward_agent] = true

# the url for your repository
set :repository,  "git@github.com:arrel/qamio.git"
set :branch, "master"
set :site_root, "rails"

# Your svn / git login name
# set :scm_passphrase, Proc.new { CLI.password_prompt "Git Passphrase: "}
set :scm_user, Proc.new { CLI.password_prompt "Git User: "}

# use update of a cached copy of the svn rather than a full checkout every time
# set :deploy_via, :remote_cache
set :deploy_subdir, "rails"
set :copy_exclude, [".DS_Store"]
set :repository_cache, "cached-copy"


#---------------------------------------------------------------------------------------------
# HOOKS
#---------------------------------------------------------------------------------------------

after "deploy:update_code", "deploy_custom:link_configs"


#---------------------------------------------------------------------------------------------
# ENVIRONMENTS
#---------------------------------------------------------------------------------------------

##################################################
# PRODUCTION
##################################################

# set :rails_env, "production"
# 
# # NOTE: for some reason Capistrano requires you to have both the public and
# # the private key in the same folder, the public key should have the extension ".pub".
# ssh_options[:keys] = ["#{ENV['HOME']}/.ssh/chiivelive.pem"]
# 
# set :server_name, "ec2-184-73-225-231.compute-1.amazonaws.com" 
# set :ebs_volume, "vol-49963c20"
# 
# set :ec2onrails_config, 
# {
#   :restore_from_bucket => "chiive-archive",
#   :restore_from_bucket_subdir => "database",
#   
#   :archive_to_bucket => "chiive-archive",
#   :archive_to_bucket_subdir => "db-archive/#{Time.new.strftime('%Y-%m-%d--%H-%M-%S')}",
#   
#   :packages => ["logwatch", "imagemagick"],
#   :timezone => "UTC",
#   :mail_forward_address => "arrel@17feet.com",
# }

##################################################
# STAGING (overwrites Production values if set)
##################################################

set :rails_env, "staging"
ssh_options[:keys] = ["#{ENV['HOME']}/.ssh/chiivestaging.pem"]

set :server_name, "ec2-174-129-74-75.compute-1.amazonaws.com"
set :ebs_volume, "vol-871fb4ee"

set :ec2onrails_config, 
{
  :restore_from_bucket => "chiive-staging-archive",
  :restore_from_bucket_subdir => "database",
  
  :archive_to_bucket => "chiive-staging-archive",
  :archive_to_bucket_subdir => "db-archive/#{Time.new.strftime('%Y-%m-%d--%H-%M-%S')}",
  
  :packages => ["logwatch", "imagemagick"],
  :timezone => "UTC",
  :mail_forward_address => "arrel@17feet.com",
}

# The domain name of the server to deploy to, this can be your domain or the domain of the server.
role :app,      server_name
role :web,      server_name
role :memcache, server_name
role :proxy,    server_name
role :db,       server_name, :primary => true, :ebs_vol_id => ebs_volume # Uses MySQL @ ebs



#---------------------------------------------------------------------------------------------
# Monitoring
#---------------------------------------------------------------------------------------------

desc "Returns last lines of log file. Usage: cap log [-s lines=100] [-s rails_env=production]"
task :log do
  lines     = 100 #configuration.variables[:lines] || 100
  run "tail -n #{lines} #{shared_path}/log/#{rails_env}.log" do |ch, stream, out|
    puts out
  end
end



#---------------------------------------------------------------------------------------------
# Deployment
#---------------------------------------------------------------------------------------------
namespace(:deploy_custom) do
  task :link_configs, :roles => :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/facebooker.yml #{release_path}/config/facebooker.yml"
    run "ln -nfs #{shared_path}/config/s3.yml #{release_path}/config/s3.yml"
  end
end



#---------------------------------------------------------------------------------------------
# DB backup
#---------------------------------------------------------------------------------------------

desc "Creates a backup of the DB on EC2 and downloads it locally"
task :download_ec2_db do
  
  # 1. Load DATABASE yaml file
  puts ">> Load DATABASE yaml file"
  app_db = YAML.load_file("./config/database.yml")
  
  # 2.
  db_name = app_db[rails_env]["database"]
  db_user = app_db[rails_env]["username"]
  db_pass = app_db[rails_env]["password"]
  short_timestamp = Time.now.to_i
  long_timestamp = Time.now.strftime("%Y_%m_%d__%H_%M__%S")
  filename_server = "#{rails_env}_db_backup__#{long_timestamp}.sql"
  filename_local = "#{rails_env}_db_backup.sql"

  # 3. MYSQL Backup
  puts ">> Start: MYSQL Backup"
  #run "mysqldump -u chiive_admin -pf33t17 chiivestaging > staging_db_backup.sql" do |ch, stream, out|
  run "mysqldump -u #{db_user} -p#{db_pass} #{db_name} > #{filename_server}" do |ch, stream, out|
     puts out
  end
  
  # 4. Download the backup
  puts ">> Download: MYSQL Backup"
  #download "staging_db_backup.sql", "staging_db_backup.sql"
  download filename_server, filename_local
  
  puts ">> END <<"
end

