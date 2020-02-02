class CreateLmsLoans < ActiveRecord::Migration[5.0]
  def change
    create_table :lms_loans do |t|
      t.float :amount
      t.float :interest
      t.integer :period_count
      t.string :period
      t.timestamp :start_date
      t.string :date_pointer
      t.jsonb :custom_payments, default: {}
      t.jsonb :expected_payments, default: {}

      t.timestamps
    end
  end
end
