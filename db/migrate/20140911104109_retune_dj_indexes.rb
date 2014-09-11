class RetuneDjIndexes < ActiveRecord::Migration
  def up
    
    remove_index :delayed_jobs, [:priority, :run_at]
    remove_index :delayed_jobs, :queue
    remove_index :delayed_jobs, [:locked_at, :run_at]
    remove_index :delayed_jobs, :locked_by
    remove_index :delayed_jobs, :failed_at
    
    add_index :delayed_jobs, [ :priority, :run_at], :name=>:dj_priority
    add_index :delayed_jobs, [:locked_at, :locked_by], :name=>:dj_locking
    
  end

  def down
    
    remove_index :delayed_jobs, :name=>:dj_priority
    remove_index :delayed_jobs, :name=>:dj_locking
    
    add_index :delayed_jobs, [:priority, :run_at]
    add_index :delayed_jobs, :queue
    add_index :delayed_jobs, [:locked_at, :run_at]
    add_index :delayed_jobs, :locked_by
    add_index :delayed_jobs, :failed_at
    
  end
end
