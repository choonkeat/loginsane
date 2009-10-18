class Site < ActiveRecord::Base
  has_many :services
  has_many :profiles

  validates_presence_of :name, :callback_url

  before_save :set_key_secret, :update_slug

  def set_key_secret
    self.secret = Digest::SHA1.hexdigest("#{Time.now.to_f}#{rand(Time.now.to_i)}") if self.secret.blank?
    self.key    = Digest::SHA1.hexdigest("#{Time.now.to_f}#{rand(Time.now.to_i)}#{self.secret}") if self.key.blank?
  end

  def update_slug
    self.slug = self.name.to_s.downcase.strip.gsub(/\W+/, '-')
  end

  def to_param
    self.slug
  end
end
