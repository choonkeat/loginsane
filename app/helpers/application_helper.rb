# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def bread_crumb(*args)
    "<h5 class='bread'>#{args.collect {|(txt,link)| link_to_unless_current(h(txt), link) }.join(' &raquo; ')}</h5>"
  end
end
