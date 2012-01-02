class CreateActionSmserDeliveryReports < ActiveRecord::Migration
  def change
    create_table :action_smser_delivery_reports do |t|
      t.string :msg_id
      t.string :status
      t.datetime :status_updated_at
      t.string :recipient
      t.string :sender
      t.string :text_body

      t.timestamps
    end
  end
end
