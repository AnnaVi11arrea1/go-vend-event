  namespace :csv do
    desc "Create sample data"

    task admin: :environment do
      if Rails.env.development?
        user = User.new(
          id: 1,
          email: 'stayfluorescent@gmail.com',
          first_name: 'Anna',
          last_name: 'Villarreal',
          password: 'password',
          username: 'everfluorescent'
        )
        user.save!
        puts "Admin user created with email: #{user.email}" if user.persisted?
      end
    
      if !Rails.env.development? && User.count == 0
        user = User.new(
          id: 1,  
          email: 'stayfluorescent@gmail.com',
          first_name: 'Anna',
          last_name: 'Villarreal',
          password: 'password',
          username: 'everfluorescent'
        )
        user.save!
        puts "Admin user created with email: #{user.email}" if user.persisted?
      end
    end
  
    task events: :environment do
      if Rails.env.production?
        Event.where(:host_id => 1).destroy_all
      end
      require 'csv'
      csv_file = File.read(Rails.root.join('lib', 'csvs', 'events.csv')) # Adjust the path
      csv = CSV.parse(csv_file, :headers => true, :encoding => 'ISO-8859-1')
      csv.each do |row|
        Event.find_or_create_by!(
          id: row['id'], # assign original primary key
          name: row['name'],
          application_due_at: row['application_due_at'],
          application_link: row['application_link'],
          information: row['information'],
          photo: row['photo'],
          started_at: row['started_at'],
          tags: row['tags'],
          address: row['address'],
          host_id: row['host_id'],
          latitude: row['latitude'],
          longitude: row['longitude'],
        ) 
      end
      puts "Import completed!"
    end

    task users: :environment do
      if Rails.env.development?
        FollowRequest.destroy_all
        Event.destroy_all
        User.destroy_all
      end 

      NUM_USERS = 10
      PASSWORD = "password"
      EVENT_TAGS = ["art", "music", "food", "fashion", "tech", "festival", "camping", "market"]
      EVENT_DATES = ["2025-07-15", "2025-07-15", "2025-03-15"]

      users = NUM_USERS.times.map do
        first_name = Faker::Name.first_name
        last_name = Faker::Name.last_name
        username = Faker::Internet.username(specifier: "#{first_name} #{last_name}", separators: %w())
        email = Faker::Internet.email(name: "#{first_name} #{last_name}", separators: %w())
        
        User.create!(
          first_name: first_name,
          last_name: last_name,
          username: username,
          email: email,
          password: PASSWORD
          )
        end
        
        # TODO: the fake people have yet to follow eachother
        users = User.all
        users.to_a.combination(2).each do |user1, user2|
          puts "Creating follow requests for #{user1.username}"
          puts "Creating follow requests for #{user2.username}"
          next if user1 = user2
            if rand < 0.75 
              user1.sent_follow_request.create!(
                recipient: user2,
                status: FollowRequest.statuses.keys.sample
                )
              if rand < 0.75
                user2.sent_follow_request.create(
                  recipient: user1,
                  status: FollowRequest.statuses.keys.sample
                )
              end
            end
          end    

          users.each do |user|
            rand(1..10).times do
              user.events.create!(
                name: Faker::Company.name, 
                started_at: EVENT_DATES.sample, 
                tags: EVENT_TAGS.sample, 
                address: Faker::Address.full_address, 
                information: Faker::Company.catch_phrase, 
                application_due_at: Faker::Date.between(from: Date.today, to: 1.year.from_now), 
                application_link: Faker::Internet.url,
                photo: "https://picsum.photos/200",
                latitude: Faker::Address.latitude,
                longitude: Faker::Address.longitude,
                host_id: user.id
                )
              
            end
          end
          puts "There are now #{User.count} fake people in the database!"
          puts "There are now #{Event.count} fake events in the database!"
          puts "There are now #{FollowRequest.count} fake people trying to follow other fake people in the database!"
        end
      end
        
