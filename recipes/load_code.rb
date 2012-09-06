git "/srv/localwiki" do
  repository node[:localwiki][:repository][:url]
  reference node[:localwiki][:repository][:reference]
  action node[:localwiki][:repository][:action]
end
