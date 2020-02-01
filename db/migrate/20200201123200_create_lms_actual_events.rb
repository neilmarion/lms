class CreateLmsActualEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :lms_actual_events do |t|
      t.string :name
      t.jsonb :data
      t.string :date
      t.references :loan, index: true

      t.timestamps
    end
  end
end
