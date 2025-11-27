class AddIndexOnRocketsRocketUuid < ActiveRecord::Migration[8.1]
  def change
    add_index :rockets, :uuid, unique: true
  end
end
