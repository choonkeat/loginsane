# prefix all methods with name of this class

module Auth
  module Facebook
    def self.included(base)
      base.class_eval do
        before_filter :set_p3p_header, :set_facebook_session
        helper_method :facebook_session
      end
    end

    def facebook_callback
      Facebooker.with_application(@service.key) do
        create_facebook_session if facebook_session.blank?
        logger.debug "facebook_session = #{facebook_session.inspect}"
        logger.debug "facebook_session.user = #{facebook_session.user.inspect}"
        hash = {
          :providerName      => "facebook",
          :identifier        => facebook_session.user.uid,
          :displayName       => facebook_session.user.name,
          :preferredUsername => facebook_session.user.name && facebook_session.user.name.to_s.gsub(/\W+/, ''),
          :utcOffsetSeconds  => facebook_session.user.timezone && (facebook_session.user.timezone.to_f * 3600).to_i,
          :url               => facebook_session.user.profile_url,
          :photo             => facebook_session.user.pic_big || facebook_session.user.pic_square || facebook_session.user.pic_small,
          :location          => facebook_session.user.hometown_location,
          :email             => facebook_session.user.proxied_email,
          :raw               => ::Facebooker::User::FIELDS.inject({}) {|sum,key| sum.merge(key => facebook_session.user.send(key)) },
        }
        return_to_service_callback(hash)
      end
    end

    # no links to this at the moment
    def facebook_logout
      session[:facebook_session] = nil
      @callback_url = params[:return_url]
      render :action => 'return_to_service_callback', :layout => false
    end

    # regarding iframes, cookies, safari & ie6
    # see http://groups.google.com/group/facebooker/browse_thread/thread/55743ca4b224065e
    def set_p3p_header
      response.headers['P3P'] = 'CP="CAO PSA OUR"'
    end
  end
end
