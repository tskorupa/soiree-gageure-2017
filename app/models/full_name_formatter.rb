# frozen_string_literal: true
module FullNameFormatter
  extend self

  TITLEIZE_REGEX = /\b(?<!['â<80><99>`])[a-z]/
  private_constant :TITLEIZE_REGEX

  def format(full_name)
    # NOTE: the gsub portion is similar to ActiveSupport::Inflector#titleize
    #   with the difference that it doesn't underscore and humanize.
    full_name.to_s
      .strip
      .squish
      .downcase
      .gsub(TITLEIZE_REGEX, &:capitalize)
  end
end
