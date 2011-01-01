require 'ostruct'

module Auth
  module Openid
    def self.included(base)
      base.class_eval do
        # http://wilkinsonlab.ca/home/node/31 (yahoo)
        before_filter :openid_set_xrds_location
      end
    end

    # can't fetch sreg (email) attributes from yahoo
    # see http://developer.yahoo.net/forum/index.php?showtopic=641
    def openid_callback
      if using_open_id?
        key_maps = {
          # http://www.axschema.org/types
          :preferredUsername => ["nickname", "http://axschema.org/namePerson/friendly", "email", "http://axschema.org/contact/email"],
          :displayName       => ["fullname", "http://axschema.org/namePerson", ["http://axschema.org/namePerson/first", "http://axschema.org/namePerson/last"]],
          :utcOffsetSeconds  => ["timezone", "http://axschema.org/pref/timezone"],
          :location          => ["country", "http://axschema.org/contact/country/home"],
          :email             => ["email", "http://axschema.org/contact/email"],
          :url               => ["http://axschema.org/contact/web/default"],
        }
        authenticate_with_open_id(params[:openid_url], :required => key_maps.values.flatten.uniq) do  |result, identity_url, registration|
          if result.successful?
            hash = {
              :providerName => "openid",
              :identifier => identity_url,
              :raw => {:registration => registration.to_json, :params => params.to_json},
            }
            key_maps.each do |(ourkey, possible_keys)|
              possible_keys.each do |key|
                hash[ourkey].blank? && hash[ourkey] = case key
                when Array
                  key.collect {|subkey| registration[subkey].to_s }.reject(&:blank?).join(' ')
                else
                  registration[key].to_s
                end
              end
            end
            logger.debug "hash = #{hash.to_yaml}"
            return_to_service_callback(hash)
          else
            flash.now[:error] = result.message
          end
        end
      else
        flash.now[:error] = "Please provide a URL"
      end
      render :action => 'openid_form', :layout => false unless performed?
    end

    def openid_xrds
      response.headers['content-type'] = 'application/xrds+xml'
      render :text => <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<xrds:XRDS
    xmlns:xrds="xri://$xrds"
    xmlns:openid="http://openid.net/xmlns/1.0"
    xmlns="xri://$xrd*($v*2.0)">
    <XRD>
        <Service priority="1">
            <Type>http://specs.openid.net/auth/2.0/return_to</Type>
            <URI>#{callback_url_for(@service)}</URI>
        </Service>
    </XRD>
</xrds:XRDS>
EOS
    end

  protected
    # squeezing into common namespace due to 
    # open_id_authentication plugin
    def root_url
      callback_url_for(@service)
    end

    def openid_set_xrds_location
      response.headers['X-XRDS-Location'] = url_for(:action => "openid_xrds", :id => params[:id], :only_path => false)
    end

  end
end
