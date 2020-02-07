class CreateLmsActualTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :lms_actual_transactions do |t|
      t.string :type
      t.float :amount
      t.references :loan, index: true

      t.timestamps
    end
  end
end
