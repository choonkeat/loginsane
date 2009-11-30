class LoginsaneController < ApplicationController
  before_filter :set_service, :except => [:form, :embed]
  before_filter :set_site_and_service, :only => [:form, :embed]
  before_filter :set_return_url_base, :only => [:form, :embed]
  include Auth::Twitter
  include Auth::Facebook
  include Auth::Openid

  def index
    if Service.first.blank?
      flash[:notice] = "Setup at least 1 authentication service"
      return redirect_to(services_path) 
    end
  end

  def profile
    if profile = Profile.login(params[:token], params[:signature])
      respond_to do |format|
        format.xml  { render :xml  => profile.json_object.to_xml(:root => 'profile', :skip_types => true) }
        format.json { render :json => profile.json_object.to_json }
      end
    else
      render :nothing => true, :status => 404
    end
  end

protected
  # the '@service' variable will come handy inside custom methods like Auth::Facebook#facebook_callback
  def set_service
    @service = Service.find(:first, :include => [:site], :conditions => {:id => params[:id]}) if params[:id]
  end

  def set_site_and_service
    if params[:id] && @site = Site.find_by_key(params[:id])
      @service = @site.services.configured.find_by_auth_type('facebook')
    end
  end

  def set_return_url_base
    return if params[:return_url].blank?
    return_url_base = Rails.cache.fetch("#{request.remote_ip}.return_url", :expires_in => 1.hour) do
      uri = URI.parse(params[:return_url])
      uri.scheme + '://' + uri.host + (uri.port == 80 ? '' : ':' + uri.port)
    end
    logger.debug "return_url_base => #{return_url_base.inspect}"
  end

  def return_to_service_callback(hash)
    if hash[:email].to_s.blank?
      # no email, nevermind
    elsif hash[:photo].blank?
      # try our luck with gravatar (intentionally request for 404 instead of redirect to default gravatar pic)
      hash[:photo] = "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(hash[:email].to_s)}.jpg?d=404"
    end
    if profile = @service.profiles.find_by_identifier(hash[:identifier])
      profile.update_attributes! :json_text => hash.to_json
    else
      profile = @service.profiles.create!({ :site_id => @service.site_id, :identifier => hash[:identifier], :json_text => hash.to_json })
    end
    return_url_base = Rails.cache.read("#{request.remote_ip}.return_url")
    Rails.cache.delete("#{request.remote_ip}.return_url")
    uri = return_url_base ? URI.join(return_url_base.to_s, @service.site.callback_url) : URI.parse(@service.site.callback_url)
    uri.query = [uri.query, "token=#{profile.token}"].reject(&:blank?).join('&')
    @callback_url = uri.to_s
    logger.debug "Returning to #{@callback_url}"
    render :action => 'return_to_service_callback', :layout => false
  end

end
