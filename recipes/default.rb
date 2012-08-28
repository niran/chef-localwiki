include_recipe "geodjango"
include_recipe "python::pip"
include_recipe "python::virtualenv"

package "git"
package "python-imaging"
package "python-lxml"
package "solr-jetty"

python_virtualenv "/usr/lib/virtualenvs/localwiki" do
  action :create
  options "--system-site-packages"
end

cookbook_file "/etc/bash.bashrc" do
  mode 0644
end
