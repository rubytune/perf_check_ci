class PerfCheckJob < ActiveRecord::Base
  include PgSearch

  after_create :enqueue!

  state_machine :status, initial: :new do
    state :queued
    state :running
    state :completed
    state :failed
    state :canceled

    event :enqueue! do
      transition [:new] => :queued
    end

    event :run! do
      transition [:queued] => :running
    end

    event :complete! do
      transition [:running] => :completed
    end

    event :fail! do
      transition [:running] => :failed
    end

    event :cancel! do
      transition any => :canceled
    end

    after_transition [:new] => :queued, do: :set_queued_at!
    after_transition [:new] => :queued, do: :perform_perf_check_benchmarks!

    after_transition [:queued] => :running, do: :set_run_at!

    after_transition [:running] => :completed, do: :set_completed_at!
    after_transition [:running] => :failed, do: :set_failed_at!
    after_transition [:running] => :canceled, do: :set_canceled_at!      
  end

  def set_canceled_at!
    touch(:canceled_at)
  end

  def set_queued_at!
    touch(:queued_at)
  end

  def set_run_at!
    touch(:run_at)
  end

  def set_completed_at!
    touch(:completed_at)
  end

  def set_failed_at!
    touch(:failed_at)
  end

  def perform_perf_check_benchmarks!
    PerfCheckJobWorker.perform_async(id)
  end

  def run_benchmarks!
    true
  end
end
