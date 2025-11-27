class CreateRockets < ActiveRecord::Migration[8.1]
  def change
    create_table :rockets do |t|
      t.uuid :uuid
      t.string :status
      t.string :rocket_type
      t.integer :speed
      t.string :mission
      t.string :accident
      t.integer :last_processed_message_number
      t.datetime :last_processed_message_at

      t.timestamps
    end
  end
end
