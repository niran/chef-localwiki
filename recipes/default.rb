include_recipe "geodjango"
include_recipe "python::pip"
include_recipe "python::virtualenv"

python_virtualenv "/usr/lib/virtualenvs/localwiki" do
  action :create
  options "--system-site-packages"
end
