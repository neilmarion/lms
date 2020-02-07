class CreateLmsExpectedPayments < ActiveRecord::Migration[5.0]
  def change
    create_table :lms_expected_payments do |t|
      t.string :name
      t.float :amount
      t.references :loan, index: true

      t.timestamps
    end
  end
end
