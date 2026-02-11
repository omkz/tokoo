class CreateLoginActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :login_activities do |t|
      t.references :user, null: false, foreign_key: true
      t.string :identity
      t.string :ip_address
      t.string :user_agent
      t.boolean :success
      t.string :failure_reason

      t.timestamps
    end
  end
end
