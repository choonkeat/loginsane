class Service < ActiveRecord::Base
  belongs_to :site
  has_many :profiles
  named_scope :notconfigured, :conditions => "auth_type IS NULL"
  named_scope :configured, :conditions => "auth_type IS NOT NULL"
  attr_accessor :callback_url
  after_save :update_config_file

  def update_config_file
    case self.auth_type
    when 'facebook'
      uri = URI.parse(self.callback_url)
      uri.path = '/'
      update_yaml_file("facebooker.yml") do |hash|
        ['development', 'production'].each do |env|
          hash[env] ||= {}
          hash[env]['alternative_keys'] ||= {}
          hash[env]['alternative_keys'][self.key] = 
            (hash[env].inject({}) {|sum,(k,v)| k == 'alternative_keys' ? sum : sum.merge(k => v) }).merge({
            'secret_key' => self.secret,
            'callback_url' => uri.to_s,
          })
        end
      end
      Facebooker.load_configuration("#{Rails.root}/config/facebooker.yml")
    when 'twitter'
      update_yaml_file("oauth.yml") do |hash|
        [self.to_param].each do |env|
          hash[env] ||= {}
          hash[env]['site'] = 'http://twitter.com/'
          hash[env]['consumer_key'] = self.key
          hash[env]['consumer_secret'] = self.secret
        end
      end
    end
  end

protected
  def update_yaml_file(filename)
    fullpath = File.join(Rails.root, "config", filename)
    logger.info "fullpath = #{fullpath} #{File.exists?(fullpath).inspect}"
    hash = if File.exists?(fullpath)
      YAML.load(IO.read(fullpath))
    elsif File.exists?(fullpath + ".template")
      YAML.load(IO.read(fullpath + ".template"))
    else
      {}
    end
    yield hash
    open(fullpath, "w") do |f|
      f.write(hash.to_yaml)
    end
  end
end
