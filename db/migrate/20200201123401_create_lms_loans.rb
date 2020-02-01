class CreateLmsLoans < ActiveRecord::Migration[5.0]
  def change
    create_table :lms_loans do |t|
      t.string :amount
      t.string :interest_per_day
      t.string :term_count
      t.timestamp :start_date

      t.timestamps
    end
  end
end
