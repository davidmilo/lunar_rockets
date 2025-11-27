class CreateRocketMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :rocket_messages do |t|
      t.references :rocket, null: false, foreign_key: true
      t.string :type
      t.integer :number
      t.datetime :time
      t.jsonb :message

      t.timestamps
    end
  end
end
