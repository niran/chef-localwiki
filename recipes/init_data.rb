DATA_DIR = "/usr/share/localwiki/"
SETTINGS_DIR = "#{DATA_DIR}conf/"
DEFAULTS_DIR = "/srv/localwiki/sapling/etc/install_config/defaults/localwiki/"

bash "copy_defaults" do
  code <<-EOH
    mkdir -p #{DATA_DIR}
    cp -r #{DEFAULTS_DIR}* #{DATA_DIR}
    mv #{SETTINGS_DIR}localsettings.py.template #{SETTINGS_DIR}localsettings.py
  EOH
  not_if "test -f #{SETTINGS_DIR}localsettings.py"
end
