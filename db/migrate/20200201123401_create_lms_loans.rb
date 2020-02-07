class CreateLmsLoans < ActiveRecord::Migration[5.0]
  def change
    create_table :lms_loans do |t|
      t.float :amount
      t.float :interest
      t.integer :period_count
      t.string :period
      t.timestamp :start_date
      t.jsonb :initial_repayment_schedule, default: {}

      t.timestamps
    end
  end
end
