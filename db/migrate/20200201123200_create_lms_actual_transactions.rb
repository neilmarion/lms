class CreateLmsActualTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :lms_actual_transactions do |t|
      t.string :kind
      t.float :amount
      t.string :note
      t.float :fee_amount
      t.float :interest_amount
      t.float :principal_amount
      t.references :loan, index: true

      t.timestamps
    end
  end
end
