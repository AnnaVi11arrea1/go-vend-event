namespace :vendor_events do
  desc "Remove orphaned vendor events (missing event or user). Set DRY_RUN=true to preview."
  task cleanup_orphans: :environment do
    dry_run = ENV["DRY_RUN"].to_s.downcase == "true"

    missing_event = VendorEvent.where.missing(:event)
    missing_user = VendorEvent.where.missing(:user)
    orphan_ids = (missing_event.pluck(:id) + missing_user.pluck(:id)).uniq
    orphan_scope = VendorEvent.where(id: orphan_ids)

    total_orphans = orphan_scope.count

    puts "Orphaned vendor events found: #{total_orphans}"
    puts "- Missing event: #{missing_event.count}"
    puts "- Missing user: #{missing_user.count}"

    if total_orphans.zero?
      puts "Nothing to clean."
      next
    end

    if dry_run
      puts "DRY_RUN=true, no records deleted."
      next
    end

    deleted_count = orphan_scope.destroy_all.size
    puts "Deleted orphaned vendor events: #{deleted_count}"
  end
end
