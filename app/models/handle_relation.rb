# frozen_string_literal: true

module HandleRelation
  extend self

  def find_or_build(klass:, supplied_full_name:, actual_entity: nil)
    return if supplied_full_name.blank?
    return(actual_entity) if actual_entity.try(:full_name) == supplied_full_name

    existing_entity = klass.find_by(full_name: supplied_full_name)
    return(existing_entity) if existing_entity

    klass.new(full_name: supplied_full_name)
  end
end
