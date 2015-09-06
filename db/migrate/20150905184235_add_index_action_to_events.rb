class AddIndexActionToEvents < ActiveRecord::Migration
  def change
  	add_index :events, :action
  end
end
