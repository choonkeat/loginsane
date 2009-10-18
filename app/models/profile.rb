class Profile < ActiveRecord::Base
  belongs_to :site
  belongs_to :service
  before_save :regenerate_token

  def regenerate_token
    self.token = Digest::SHA1.hexdigest("#{Time.now.to_f}#{rand(Time.now.to_i)}#{self.json_text}")
  end

  def self.login(token, your_signature)
    profile = self.find(:first, :conditions => ["updated_at > ? AND token = ?", 15.minutes.ago, token])
    my_basestring = [token, profile.try(:site).try(:secret).to_s].join('')
    my_signature = Digest::SHA1.hexdigest(my_basestring)
    logger.debug ["your sig=", your_signature, "vs mine sig=", my_signature, " my base_string=", my_basestring].inspect
    if profile && profile.site && your_signature == my_signature
      profile.update_attribute :lastlogin_at, Time.now
      return profile
    else
      return nil
    end
  end

  def json_object
    @json ||= JSON.parse(self.json_text)
    @json['id'] = self.id
    @json
  end
end
