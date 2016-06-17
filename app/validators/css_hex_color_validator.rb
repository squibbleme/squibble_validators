# Diese Klasse kuemmert sich um die Validierung von HEX Farbcodes.
class CssHexColorValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    return if value =~ /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/i
    object.errors[attribute] << (options[:message] || I18n.t('validators.css_hex_color_validator'))
  end
end
