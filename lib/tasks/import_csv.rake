  namespace :csv do
    desc "Import data from CSV into Users"

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

      if User.count < 20
      10.times do 
        first_name = Faker::Name.first_name
        last_name = Faker::Name.last_name
        username = Faker::Internet.username(specifier: "#{first_name} #{last_name}", separators: %w())
        email = Faker::Internet.email(name: "#{first_name} #{last_name}", separators: %w())
        password = "password"
        User.create(
          first_name: first_name,
          last_name: last_name,
          username: username,
          email: email,
          password: password,
        )
      end
    
        
      
        users = User.all
        users.each do |first_user|
          puts "Creating follow requests for #{first_user.username}"
          users.each do |second_user|
            puts "Creating follow requests for #{second_user.username}"
            next if first_user == second_user
            if rand < 0.75
              follow_request = first_user.sent_follow_requests.create(
                sender: first_user,
                recipient: second_user,
                status: FollowRequest.statuses.keys.sample
              )
            end
            if rand < 0.75
              follow_request = second_user.sent_follow_requests.create(
                sender: second_user,
                recipient: first_user,
                status: FollowRequest.statuses.keys.sample
              )
            end 
          end
        end
      

        
        # users.each do |user|
        #   rand(10).times do
        #     user.events.create!(
        #       name: Faker::Company.name, 
        #       started_at: ["2025-07-15", "2025-071-15", "2025-03-15"].sample, 
        #       tags: ["art", "music", "food", "fashion", "tech", "festival", "camping", "market"].sample, 
        #       address: Faker::Address.full_address, 
        #       information: Faker::Company.catch_phrase, 
        #       application_due_at: Faker::Date.between(from: Date.today, to: 1.year.from_now), 
        #       application_link: Faker::Internet.url,
        #       photo: "https://picsum.photos/200",
        #       latitude: Faker::Address.latitude,
        #       longitude: Faker::Address.longitude,
        #       host_id: user.id,
        #     )
        #   end
        # end
      end
      
  puts "There are now #{User.count} fake people in the database!"
  puts "There are now #{Event.count} fake events in the database!"
  puts "There are now #{FollowRequest.count} fake people trying to follow other fake people in the database!"
end
end
