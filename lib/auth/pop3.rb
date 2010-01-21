require 'net/pop'

module Auth
  module POP3
    def pop3_callback
      if params[:pop3_username] && params[:pop3_password] && params[:pop3_server]
        begin
          Rails.logger.debug "Logging into #{params[:pop3_server]} ... "
          pop = Net::POP3.new(params[:pop3_server])
          Rails.logger.debug "Logging in as #{params[:pop3_username]} ... "
          pop.start params[:pop3_username], params[:pop3_password]
          pop.finish
          hash = {
            :providerName      => "pop3",
            :identifier        => [params[:pop3_username], params[:pop3_server]].join('@'),
            :preferredUsername => params[:pop3_username].gsub(/@.*$/, ''),
            :displayName       => params[:pop3_username].gsub(/@.*$/, ''),
            :email             => params[:pop3_username],
          }
          return_to_service_callback(hash)
        rescue Net::POPAuthenticationError
          Rails.logger.error $!
          Rails.logger.error $@
          flash[:error] = $!.to_s
        end
      end
      render :action => 'pop3_form', :layout => false unless performed?
    end
  end
end
