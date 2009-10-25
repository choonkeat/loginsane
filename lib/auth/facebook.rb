# prefix all methods with name of this class

module Auth
  module Facebook
    def self.included(base)
      base.class_eval do
        around_filter :facebook_set_current_application
        before_filter :facebook_set_p3p_header, :facebook_set_facebook_session
        helper_method :facebook_session
      end
    end

    def facebook_callback
      create_facebook_session if facebook_session.blank?
      return facebook_js_redirect_login if facebook_session.blank?
      logger.debug "facebook_session = #{facebook_session.inspect}"
      logger.debug "facebook_session.user = #{facebook_session.user.inspect}"
      hash = {
        :providerName      => "facebook",
        :identifier        => facebook_session.user.uid,
        :displayName       => facebook_session.user.name,
        :preferredUsername => facebook_session.user.username || facebook_session.user.name && facebook_session.user.name.to_s.gsub(/\W+/, ''),
        :utcOffsetSeconds  => facebook_session.user.timezone && (facebook_session.user.timezone.to_f * 3600).to_i,
        :url               => facebook_session.user.profile_url,
        :photo             => facebook_session.user.pic_big || facebook_session.user.pic_square || facebook_session.user.pic_small,
        :location          => facebook_session.user.hometown_location,
        :email             => facebook_session.user.proxied_email,
        :raw               => ::Facebooker::User::FIELDS.inject({}) {|sum,key| sum.merge(key => facebook_session.user.send(key)) },
      }
      return_to_service_callback(hash)
    rescue Facebooker::Session::SessionExpired
      logger.warn $!; logger.warn $!.backtrace.first
      # rid the bad cookies
      session[:facebook_session] = nil
      cookies.keys.inject(Regexp.new(@service.key)) do |regexp, key|
        cookies.delete(key) if regexp.match(key)
        regexp
      end
      return facebook_js_redirect_login
    end

    def facebook_js_redirect_login
      javascript_code = "<script>window.top.location.href = '#{Facebooker.login_url_base}&fbconnect=true&return_session=false&next=#{URI.escape(callback_url_for(@service))}';</script>"
      logger.debug "facebook_js_redirect_login: #{javascript_code}"
      render :text => javascript_code
    end

    # no links to this at the moment
    def facebook_logout
      session[:facebook_session] = nil
      @callback_url = params[:return_url]
      render :action => 'return_to_service_callback', :layout => false
    end

  protected
    # regarding iframes, cookies, safari & ie6
    # see http://groups.google.com/group/facebooker/browse_thread/thread/55743ca4b224065e
    def facebook_set_p3p_header
      response.headers['P3P'] = 'CP="CAO PSA OUR"'
    end

    def facebook_set_current_application(&block)
      if @service.try(:auth_type) == 'facebook'
        Facebooker.with_application(@service.key, &block)
      else
        yield
      end
    end

    def facebook_set_facebook_session
      set_facebook_session if @service.try(:auth_type) == 'facebook'
    end

  end
end
