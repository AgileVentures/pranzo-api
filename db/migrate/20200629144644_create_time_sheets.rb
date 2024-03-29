class CreateTimeSheets < ActiveRecord::Migration[6.0]
  def change
    create_table :time_sheets do |t|
      t.date :date
      t.time :start_time
      t.time :end_time
      t.decimal :duration
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
