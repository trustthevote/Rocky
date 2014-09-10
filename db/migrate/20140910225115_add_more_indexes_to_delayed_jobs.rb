class AddMoreIndexesToDelayedJobs < ActiveRecord::Migration
  def self.up
    add_index :delayed_jobs, [:locked_at, :run_at]
    add_index :delayed_jobs, :locked_by
    add_index :delayed_jobs, :failed_at
  end

  def self.down
    remove_index :delayed_jobs, [:locked_at, :run_at]
    remove_index :delayed_jobs, :locked_by
    remove_index :delayed_jobs, :failed_at
  end
end
