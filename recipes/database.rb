::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

# randomly generate postgres password
node.set_unless[:localwiki][:database][:password] = secure_password

user = node[:localwiki][:database][:user]
password = node[:localwiki][:database][:password]
db_name = node[:localwiki][:database][:db_name]

bash "create_user" do
  user "postgres"
  code "psql -c \"CREATE USER #{user} WITH PASSWORD '#{password}'\""
  not_if %Q{
    psql -c \"SELECT usename FROM pg_catalog.pg_user\" |
      tail -n +3 | head -n -2 | grep \"#{user}\"
    }, :user => "postgres"
end

bash "create_database" do
  user "postgres"
  code "createdb -E UTF8 -T template_postgis -O #{user} #{db_name}"
  not_if %Q{
    psql -c "SELECT datname FROM pg_database WHERE datistemplate = false;" |
      tail -n +3 | head -n -2 | grep "#{db_name}"
    }, :user => "postgres"
end

SETTINGS_FILE = "/usr/share/localwiki/conf/localsettings.py"

bash "write_settings" do
  code %Q{
    sed s/DBNAMEHERE/#{db_name}/ < #{SETTINGS_FILE} |
      sed s/DBUSERNAMEHERE/#{user}/ |
      sed s/DBPASSWORDHERE/#{password}/ > #{SETTINGS_FILE}.replaced
    mv #{SETTINGS_FILE}.replaced #{SETTINGS_FILE}
    }
end

directory "/tmp/chef-localwiki/"
cookbook_file "/tmp/chef-localwiki/superuser_exists.py"

bash "set_superuser_flag_pre_create" do
  cwd "/srv/localwiki/sapling/"
  environment "LOCALWIKI_DATA_ROOT" => "/usr/share/localwiki/",
    "PYTHONPATH" => "."
  code %Q{
    source /usr/lib/virtualenvs/localwiki/bin/activate
    python /tmp/chef-localwiki/superuser_exists.py #{node[:localwiki][:superuser][:username]}
  }
end

bash "create_superuser" do
  cwd "/srv/localwiki/sapling/"
  environment "LOCALWIKI_DATA_ROOT" => "/usr/share/localwiki/",
    "PYTHONPATH" => "."
  code %Q{
    source /usr/lib/virtualenvs/localwiki/bin/activate
    python manage.py syncdb --noinput --migrate
    python manage.py createsuperuser --noinput \
      --username=#{node[:localwiki][:superuser][:username]} \
      --email=#{node[:localwiki][:superuser][:email]}
    python /tmp/chef-localwiki/superuser_exists.py #{node[:localwiki][:superuser][:username]}
  }
  creates "/usr/share/localwiki/conf/superuser_created"
end

bash "run_setup_all" do
  cwd "/srv/localwiki/sapling/"
  environment "LOCALWIKI_DATA_ROOT" => "/usr/share/localwiki/"
  code %Q{
    source /usr/lib/virtualenvs/localwiki/bin/activate
    python manage.py setup_all
    }
end
