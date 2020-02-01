class CreateLmsEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :lms_events do |t|
      t.string :name
      t.string :data

      t.timestamps
    end
  end
end
