# frozen_string_literal: true
module TablesHelper
  def table_column_name
    Table.model_name.human
  end
end
