class CreateLmsExpectedTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :lms_expected_transactions do |t|
      t.string :type
      t.float :amount
      t.date :date
      t.references :loan, index: true

      t.timestamps
    end
  end
end
