class ApplicationController < ActionController::Base
  include Pagy::Backend
  protect_from_forgery with: :exception
  before_action :require_user
  
  private

  def require_user
    if current_user.blank?
      redirect_to login_path
      return false
    end
  end

  def require_no_user
    if current_user.present?
      redirect_to root_path
      return false
    end
  end

  def load_perf_check_jobs
    if params[:search].present?
      @perf_check_jobs = PgSearch.multisearch(params[:search]).page(params[:page]).per(params[:per]).map(&:searchable)
    else
      @perf_check_jobs, @perf_check_jobs_records = pagy(PerfCheckJob.most_recent)
    end
  end
end
