class CreateExercices < ActiveRecord::Migration
  def change
    create_table :exercices do |t|
      t.string :name
      t.text :content
      t.string :equation
      t.float :weight
      t.string :solution
      t.integer :star

      t.timestamps
    end
  end
end
