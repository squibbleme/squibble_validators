# Validierung von E-Mail Adressen
#
class EmailValidator < ActiveModel::EachValidator
  def self.regexp(options = {})
    name_validation = options[:strict_mode] ? '-a-z0-9+._' : '^@\\s'
    /\A\s*([#{name_validation}]{1,64})@((?:[-a-z0-9]+\.)+[a-z]{2,})\s*\z/i
  end

  def self.valid?(value, options = {})
    (value =~ regexp(options))
  end

  def validate_each(record, attribute, value)
    return if self.class.valid?(value, options)
    record.errors.add(attribute, options[:message] || :invalid)
  end
end
