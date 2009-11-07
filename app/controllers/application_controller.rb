# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

protected
  def callback_url_for(service)
    url_for(:controller => 'loginsane', :action => "#{service.auth_type}_callback", :id => service, :only_path => false)
  end
  helper_method :callback_url_for

  def require_admin_user
    allowed_profile_ids = [1]
    if allowed_profile_ids.include?(session[:profile_id])
      true
    else
      logger.warn "Fail require_admin_user: #{allowed_profile_ids.inspect}.include?(#{session[:profile_id].inspect})"
      if root_site = Site.first
        flash[:notice] = "Please login to access the Loginsane Control Panel"
      else
        flash[:notice] = "Login now to establish the super-user account for this Loginsane installation"
        Site.transaction do
          root_site = Site.create!({
            :name => "Loginsane Control Panel", :callback_url => login_sites_url,
            :css => IO.read("#{Rails.root}/public/stylesheets/loginsane.css"),
          })
          root_site.services.create!({
            :auth_type => 'openid', :name => 'Open ID',
            :icon => [ActionController::Base.relative_url_root || "", "images/openid-logo-wordmark.png"].join("/"),
          })
          root_site.services.create!({
            :auth_type => 'openid', :name => 'Google',
            :key => 'https://www.google.com/accounts/o8/id',
            :icon => [ActionController::Base.relative_url_root || "", "images/google_logo.gif"].join("/"),
          })
          root_site.services.create!({
            :auth_type => 'openid', :name => 'Yahoo',
            :key => 'http://yahoo.com/',
            :icon => "http://l.yimg.com/a/i/reg/openid/buttons/14.png",
          })
        end
      end
      redirect_to preview_site_path(root_site)
      false
    end
  end

end
