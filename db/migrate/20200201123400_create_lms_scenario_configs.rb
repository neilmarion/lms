class CreateLmsScenarioConfigs < ActiveRecord::Migration[5.0]
  def change
    create_table :lms_scenario_configs do |t|
      t.string :name
      t.string :data
      t.references :loan, index: true

      t.timestamps
    end
  end
end
