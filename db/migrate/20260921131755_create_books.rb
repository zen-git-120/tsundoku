class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.integer :status, null: false, default: 0
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
