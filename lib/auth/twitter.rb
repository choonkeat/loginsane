# prefix all methods with name of this class

module Auth
  module Twitter
    def twitter_redirect
      request_token = twitter_get_consumer.get_request_token(:oauth_callback => callback_url_for(@service))
      session[:request_token_service] = params[:id]
      session[:request_token] = request_token
      redirect_to request_token.authorize_url
    end

    def twitter_callback
      logger.debug "session[:request_token] = #{session[:request_token].inspect}"
      session[:request_token].consumer = twitter_get_consumer
      access_token = session[:request_token].get_access_token(:oauth_verifier => params[:oauth_verifier])
      raw  = Hash.from_xml(access_token.get("/account/verify_credentials.xml").body)
      hash = {
        :providerName      => "twitter",
        :identifier        => raw['user']['id'],
        :displayName       => raw['user']['screen_name'],
        :preferredUsername => raw['user']['name'],
        :utcOffsetSeconds  => raw['user']['utc_offset'],
        :url               => raw['user']['url'],
        :photo             => raw['user']['profile_image_url'],
        :location          => raw['user']['location'],
        :raw               => raw,
      }
      return_to_service_callback(hash)
    rescue Net::HTTPServerException # Timeout, etc
      render :text => "Failed. Please try again. (#{CGI.escapeHTML($!.to_s)})"
    end

  protected
    def twitter_get_consumer
      @config   ||= YAML.load(IO.read(File.join(Rails.root, "config/oauth.yml")))[params[:id]]
      @consumer ||= OAuth::Consumer.new @config["consumer_key"], @config["consumer_secret"], {:site => @config["site"] }
    end
  end
end
