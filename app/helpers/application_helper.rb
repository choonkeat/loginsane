# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def bread_crumb(*args)
    "Hi #{h(session[:profile_name])} | #{button_to("Logout", logout_sites_path)}" +
    "<h5 class='bread'>#{args.collect {|(txt,link)| link_to_unless_current(h(txt), link) }.join(' &raquo; ')}</h5>"
  end
  def display_flash(type, content)
    "<p class=\"#{h(type)}\">#{h(content)}</p>" if not content.blank?
  end
end
