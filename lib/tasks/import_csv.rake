namespace :csv do
  desc "Create sample data"

  task admin: :environment do
    next unless Rails.env.development? || User.count.zero?

    admin_user = User.find_or_initialize_by(email: "stayfluorescent@gmail.com")
    admin_user.assign_attributes(
      first_name: "Anna",
      last_name: "Villarreal",
      password: "password",
      username: "everfluorescent"
    )
    admin_user.save!
    puts "Admin user ready: #{admin_user.email}"
  end
  
  task events: :environment do
    Event.where(host_id: 1).destroy_all if Rails.env.production?

    require "csv"
    csv_file = File.read(Rails.root.join("lib", "csvs", "events.csv"))
    csv = CSV.parse(csv_file, headers: true, encoding: "ISO-8859-1")
    csv.each do |row|
      Event.find_or_create_by!(
        id: row["id"],
        name: row["name"],
        application_due_at: row["application_due_at"],
        application_link: row["application_link"],
        information: row["information"],
        photo: row["photo"],
        started_at: row["started_at"],
        tags: row["tags"],
        address: row["address"],
        host_id: row["host_id"],
        latitude: row["latitude"],
        longitude: row["longitude"]
      )
    end
    puts "Import completed!"
  end

  task users: :environment do
    require "faker"

    # SQLite can throw BusyException when another process has the DB open.
    if ActiveRecord::Base.connection.adapter_name.downcase.include?("sqlite")
      ActiveRecord::Base.connection.execute("PRAGMA busy_timeout = 10000")
    end

    reset = ENV["RESET"].to_s.casecmp("true").zero?
    num_users = ENV.fetch("NUM_USERS", "10").to_i
    events_per_user = ENV.fetch("EVENTS_PER_USER", "3").to_i
    password = ENV.fetch("PASSWORD", "password")
    event_tags = ["art", "music", "food", "fashion", "tech", "festival", "camping", "market"]
    event_dates = ["2025-07-15", "2025-07-15", "2025-03-15"]

    if reset && Rails.env.development?
      puts "RESET=true: clearing follow requests, events, and non-admin users..."
      FollowRequest.delete_all
      Event.delete_all
      User.where.not(email: "stayfluorescent@gmail.com").delete_all
    end

    admin_user = User.find_by(email: "stayfluorescent@gmail.com")

    users = []
    created_users = 0
    num_users.times do
      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name

      user = nil
      5.times do
        username = "#{first_name.downcase}#{last_name.downcase}#{rand(1000..9999)}"
        email = "#{username}@example.test"
        user = User.new(
          first_name: first_name,
          last_name: last_name,
          username: username,
          email: email,
          password: password,
          private: [true, false].sample
        )
        break if user.save
      end

      next unless user&.persisted?

      created_users += 1
      users << user
    end

    puts "Created #{created_users} fake users"

    created_events = 0
    users.each do |user|
      events_per_user.times do
        event = user.events.new(
          name: Faker::Company.name,
          started_at: event_dates.sample,
          tags: event_tags.sample,
          address: Faker::Address.full_address,
          information: Faker::Company.catch_phrase,
          application_due_at: Faker::Date.between(from: Date.today, to: 1.year.from_now),
          application_link: Faker::Internet.url,
          photo: "https://picsum.photos/200",
          latitude: Faker::Address.latitude,
          longitude: Faker::Address.longitude,
          host_id: user.id
        )
        created_events += 1 if event.save
      end
    end

    created_follows = 0
    users.combination(2).each do |user1, user2|
      next unless rand < 0.35

      fr = user1.sent_follow_requests.find_or_initialize_by(recipient: user2)
      fr.status = FollowRequest.statuses.keys.sample
      created_follows += 1 if fr.save

      next unless rand < 0.25

      fr2 = user2.sent_follow_requests.find_or_initialize_by(recipient: user1)
      fr2.status = FollowRequest.statuses.keys.sample
      created_follows += 1 if fr2.save
    end

    if admin_user.present?
      users.each do |user|
        fr = FollowRequest.find_or_initialize_by(sender: user, recipient: admin_user)
        fr.status = FollowRequest.statuses.keys.sample
        created_follows += 1 if fr.save
      end
    end

    puts "Created #{created_events} fake events"
    puts "Created #{created_follows} follow requests"
    puts "Totals: users=#{User.count}, events=#{Event.count}, follows=#{FollowRequest.count}"
  end
end
