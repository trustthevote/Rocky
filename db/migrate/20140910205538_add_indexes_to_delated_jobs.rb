class AddIndexesToDelatedJobs < ActiveRecord::Migration
  def self.up
    add_index :delayed_jobs, [:priority, :run_at]
    add_index :delayed_jobs, :queue
  end

  def self.down
    remove_index :delayed_jobs, [:priority, :run_at]
    remove_index :delayed_jobs, :queue
  end
end
