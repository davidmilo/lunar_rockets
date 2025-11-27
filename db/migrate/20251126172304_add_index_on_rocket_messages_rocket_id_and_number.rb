class AddIndexOnRocketMessagesRocketIdAndNumber < ActiveRecord::Migration[8.1]
  def change
    add_index :rocket_messages, [:rocket_id, :number], unique: true
  end
end
