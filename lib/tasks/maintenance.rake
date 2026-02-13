namespace :maintenance do
  desc "Clean up old login logs (older than 1 year) for GDPR compliance"
  task cleanup_logs: :environment do
    # Retention period: 1 year (365 days)
    retention_period = 1.year.ago

    puts "Starting log cleanup..."

    # Clean LoginActivity
    if defined?(LoginActivity)
      deleted_count = LoginActivity.where("created_at < ?", retention_period).delete_all
      puts "Deleted #{deleted_count} old LoginActivity records."
    else
      puts "LoginActivity model not found. Skipping."
    end

    puts "Cleanup complete."
  end
end
