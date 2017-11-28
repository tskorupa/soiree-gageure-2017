# frozen_string_literal: true
module GuestsHelper
  def guest_column_name
    Guest.model_name.human
  end
end
