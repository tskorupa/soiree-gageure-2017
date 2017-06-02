# frozen_string_literal: true

module PrizesHelper
  def display_draw_position(prize)
    nth_before_last = prize.nth_before_last
    return t('column_names.prize.first_announced') if nth_before_last.nil?
    return t('column_names.prize.grand_prize') if nth_before_last.zero?
    nth_before_last.to_s
  end
end
