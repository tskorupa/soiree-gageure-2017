module HandleRelation
  extend self

  def find_or_build(klass:, supplied_full_name:, actual_entity: nil)
    return if supplied_full_name.blank?
    return(actual_entity) if actual_entity.try(:full_name) == supplied_full_name

    existing_entity = klass.search(supplied_full_name).first
    return(existing_entity) if existing_entity

    klass.new(full_name: supplied_full_name)
  end
end
