module Validations
  EMAIL_NAME = /(([\da-zA-Z])([\w+\.-]){,200})@/
  EMAIL_HOSTNAME= /(([\da-z]([\da-z-]{1,61}[\da-z])?\.)+([a-z]){2,3}(\.([a-z]){2})?)/
  EMAIL = /#{EMAIL_NAME}#{EMAIL_HOSTNAME}/
  PHONE_LOCAL = /0(?=[ ()-]{,2}[1-9])/
  PHONE_COUNTRY = /(00|\+)[1-9]\d{,2}/
  PHONE = /(#{PHONE_LOCAL}|#{PHONE_COUNTRY})([ ()-]{,2}\d){6,11}/
  IP_ADDRESS = /(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])(.\g<1>){3}/
  NUMBER = /-?(0|[1-9]\d*)(.\d+)?/
  INTEGER = /-?(0|[1-9]\d*)/
  DATE = /\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])/
  TIME = /([01]\d|2[0-3])(:[0-5]\d){2}/
  DATE_TIME = /#{DATE}( |T)#{TIME}/

  { :email? => EMAIL,
    :phone? => PHONE,
    :hostname? => EMAIL_HOSTNAME,
    :ip_address? => IP_ADDRESS,
    :number? => NUMBER,
    :integer? => INTEGER,
    :date? => DATE,
    :time? => TIME,
    :date_time? => DATE_TIME,
  }.each do |key, value|
    define_singleton_method(key) do |text|
      /\A#{value}\z/.match(text) != nil
    end
  end
end

class PrivacyFilter
  include Validations

  attr_accessor :preserve_phone_country_code
  attr_accessor :preserve_email_hostname
  attr_accessor :partially_preserve_email_username

  def initialize(text)
    @text = text
    @preserve_phone_country_code = false
    @preserve_email_hostname = false
    @partially_preserve_email_username = false
  end

  def filtered
    filter_phone filter_email @text
  end

  def filter_email(text)
    if @partially_preserve_email_username then filter_email_partially_preserve_username text
    elsif @preserve_email_hostname then filter_email_preserve_hostname text
    else text.gsub /(?<=\W|\A)#{EMAIL}(?=\W|\z)/, "[EMAIL]"
    end
  end

  def filter_email_preserve_hostname(text)
    text.gsub /(?<=\W|\A)#{EMAIL}(?=\W|\z)/ do
      "[FILTERED]@" + $4
    end
  end

  def filter_email_partially_preserve_username(text)
    text.gsub /(?<=\W|\A)#{EMAIL}(?=\W|\z)/ do
      if $1.size < 6
        "[FILTERED]@" + $4
      else
        $1.slice(0..2) + "[FILTERED]@" + $4
      end
    end
  end


  def filter_phone(text)
    if @preserve_phone_country_code then filter_phone_preserve_country_code text
    else text.gsub /(?<=\W|\A)#{PHONE}(?=\W|\z)/, "[PHONE]"
    end
  end

  def filter_phone_preserve_country_code(text)
    text.gsub /(?<=\W|\A)#{PHONE}(?=\W|\z)/ do
      if $1.size > 1
        $1 + " [FILTERED]"
      else
        "[PHONE]"
      end
    end
  end
end
