bash "setup_develop" do
  cwd "/srv/localwiki"
  code <<-EOH
    source /usr/lib/virtualenvs/localwiki/bin/activate
    python setup.py develop
  EOH
end
