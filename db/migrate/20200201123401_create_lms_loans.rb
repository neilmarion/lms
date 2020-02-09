class CreateLmsLoans < ActiveRecord::Migration[5.0]
  def change
    create_table :lms_loans do |t|
      t.float :amount
      t.float :interest
      t.integer :period_count
      t.string :period
      t.string :status, default: "ontime"
      t.timestamp :start_date

      t.timestamps
    end
  end
end
