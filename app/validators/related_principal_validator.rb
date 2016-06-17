class RelatedPrincipalValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    # Die Validierung ist nur für die :principal Relation zulässig.
    #
    if attribute != :principal
      raise ArgumentError,
            'Only allowed to use :related_principal validator for :principal relation.'
    end

    # Die Validierung erfordert mindestens eine Option.
    #
    if options[:in].nil?
      raise ArgumentError,
            'Pass at least one option for :related_principal validation.'
    end

    options[:in].each do |option|
      # Die übergebene Option ist ungültig
      #
      unless record.respond_to?(option)
        raise ArgumentError,
              "You passed a invalid option :#{option} for #{record.class}"
      end

      class_name = eval(record.reflect_on_association(option).class_name)

      begin
        relation = class_name
                   .only(:_id, :principal_id, :state)
                   .find(record.attributes["#{option}_id"])
      rescue Mongoid::Errors::InvalidFind
      rescue Mongoid::Errors::DocumentNotFound
        # Die Verbindung existiert nicht (mehr)
        raise ArgumentError,
              "Connected relation for #{record.class} ##{record.id} #{class_name} ##{record.attributes["#{option}_id"]} could not be found, because connected relation does not exists"
      rescue ActiveModel::MissingAttributeError => e
        # ap "#{record}: [#{attribute}] #{e.message}"
        # ap options

        raise ArgumentError,
              e.message.to_s
      else
        return if relation.principal_id == record.principal_id

        record.errors.add(option,
                          message: "relation #{class_name} ##{relation.principal_id} [#{relation.principal.main_domain}] has a different principal the current resource #{record.principal_id} [#{record.principal.main_domain}]")
      end
    end
  end
end
