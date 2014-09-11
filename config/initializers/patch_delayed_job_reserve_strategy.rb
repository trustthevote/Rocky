require 'delayed_job_active_record'
 
module Delayed
  module Backend
    module ActiveRecord
      class Job
        # override UPDATE..LIMIT strategy
        # see https://github.com/collectiveidea/delayed_job_active_record/issues/63#issuecomment-26284690
        def self.reserve(worker, max_run_time = Worker.max_run_time)
          if Worker.queues == ['test']
            
            now = self.db_time_now
            job = self.where({
              :locked_at=>nil,
              :queue=>'test'
            }).lock(true).first
            job.update_attributes({:locked_at => now, :locked_by => worker.name})
            job.reload
          else
            ready_scope = self.ready_to_run(worker.name, max_run_time)
            ready_scope = ready_scope.where('priority >= ?', Worker.min_priority) if Worker.min_priority
            ready_scope = ready_scope.where('priority <= ?', Worker.max_priority) if Worker.max_priority
            ready_scope = ready_scope.where(:queue => Worker.queues) if Worker.queues.any?
            ready_scope = ready_scope.by_priority
 
            now = self.db_time_now
            ready_scope.limit(worker.read_ahead).detect do |job|
              count = ready_scope.where(:id => job.id).update_all(:locked_at => now, :locked_by => worker.name)
              count == 1 && job.reload
            end
          end
        end
      end
    end
  end
end