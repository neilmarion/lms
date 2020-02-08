class CreateLmsPayments < ActiveRecord::Migration[5.0]
  def change
    create_table :lms_payments do |t|
      t.string :mode
      t.float :amount
      t.references :loan, index: true

      t.timestamps
    end
  end
end
