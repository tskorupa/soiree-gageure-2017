module FullNameFormatter
  extend self

  def format(full_name)
    full_name.to_s.strip.squish.titleize
  end
end
