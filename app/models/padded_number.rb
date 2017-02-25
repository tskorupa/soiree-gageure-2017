module PaddedNumber
  extend self

  def pad_number(number)
    return format('00%i', number) if number < 10
    return format('0%i', number) if number < 100
    number.to_s
  end
end
