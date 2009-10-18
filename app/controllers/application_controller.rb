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

end
