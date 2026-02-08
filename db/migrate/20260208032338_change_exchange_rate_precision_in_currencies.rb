class ChangeExchangeRatePrecisionInCurrencies < ActiveRecord::Migration[8.1]
  def change
    change_column :currencies, :exchange_rate, :decimal, precision: 12, scale: 6, default: 1.0
  end
end
