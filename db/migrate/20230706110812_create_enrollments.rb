class CreateEnrollments < ActiveRecord::Migration[7.0]
  def change
    create_table :enrollments do |t|
      t.references :course
      t.references :student
      t.string  :status

      t.timestamps
    end
  end
end
