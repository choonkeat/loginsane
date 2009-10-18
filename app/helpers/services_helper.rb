module ServicesHelper
  def embed_code(site)
    javascript_include_tag(actionidformat_url('loginsane', 'embed', site.key, 'js', {
      :width => '300px',
      :height => '200px',
      :frameborder => 0,
    }))
  end
end
