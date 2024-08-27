require 'json'

class UserTopUpProcessor

  # Initializes the processor with file paths
  def initialize(user_file_path, company_file_path, output_file_path, bad_user_file_path, bad_company_file_path)
    @user_file_path = user_file_path
    @company_file_path = company_file_path
    @output_file_path = output_file_path
    @bad_user_file_path = bad_user_file_path
    @bad_company_file_path = bad_company_file_path
  end

  # Main method to process user and company data
  def process
    # Load user and company data from JSON files
    users = load_json(@user_file_path, 'user')
    companies = load_json(@company_file_path, 'company')

    # Validate and separate companies into valid and invalid
    valid_companies, invalid_companies = validate_companies(companies)
    # Log any invalid company data
    write_to_bad_data_log(@bad_company_file_path, invalid_companies) if invalid_companies.any?

    # Organize valid companies by ID for easy lookup
    company_data = organize_companies(valid_companies)
    # Validate and separate users into valid and invalid
    valid_users, invalid_users = validate_users(users, company_data)
    # Log any invalid user data
    write_to_bad_data_log(@bad_user_file_path, invalid_users) if invalid_users.any?

    # Process valid users and write results to the output file
    processed_data = process_users(valid_users, company_data)
    write_to_output(processed_data)
  end

  private

  # Loads and parses JSON data from a file
  def load_json(file_path, data_type)
    JSON.parse(File.read(file_path))
  rescue Errno::ENOENT, JSON::ParserError => e
    # Handle errors related to file not found or invalid JSON format
    puts "Failed to load or parse #{data_type} file #{file_path}: #{e.message}"
    []
  end

# Validates entities (users or companies), separating valid from invalid
def validate_entities(entities, required_fields)
  valid, invalid = entities.partition do |entity|
    required_fields.all? do |field, type|
      if type == :boolean
        !!entity[field] == entity[field] # Checks if the value is boolean
      else
        entity[field].is_a?(type)
      end
    end
  end
  [valid, invalid]
end

# Validates companies
def validate_companies(companies)
  company_fields = {
    'id' => Integer,
    'name' => String,
    'top_up' => Integer,
    'email_status' => :boolean
  }
  validate_entities(companies, company_fields)
end

# Validates users based on their company association
def validate_users(users, company_data)
  user_fields = {
    'company_id' => Integer,
    'first_name' => String,
    'last_name' => String,
    'tokens' => Integer,
    'email' => String,
    'active_status' => :boolean,
    'email_status' => :boolean
  }
  valid_users, invalid_users = validate_entities(users, user_fields)
  valid_users.select! { |user| company_data[user['company_id']] } # Ensure the user's company exists
  [valid_users, invalid_users]
end

  # Organizes companies by their ID
  def organize_companies(companies)
    companies.sort_by { |company| company['id'] }
             .each_with_object({}) do |company, hash|
      hash[company['id']] = company
    end
  end

  # Processes users, calculating top-ups and preparing data for output
  def process_users(users, company_data)
    users.select { |user| company_data[user['company_id']] } # Filter users with valid companies
         .sort_by { |user| user['last_name'] } # Sort users by last name
         .group_by { |user| user['company_id'] } # Group users by their company
         .transform_values do |grouped_users|
           grouped_users.map { |user| calculate_user_topup(user, company_data[user['company_id']]) }
         end
         .sort
         .to_h
  end

  # Calculates the new token balance for a user and determines if an email should be sent
  def calculate_user_topup(user, company)
    updated_balance = user['tokens']
    if user['active_status']
      top_up_amount = company['top_up']
      updated_balance += top_up_amount
    end

    should_send_email = company['email_status'] && user['email_status']

    {
      company_id: company['id'],
      company_name: company['name'],
      full_name: "#{user['last_name']}, #{user['first_name']}",
      email: user['email'],
      initial_balance: user['tokens'],
      updated_balance: updated_balance,
      email_sent: should_send_email
    }
  end

  # Writes the processed data to the output file
  def write_to_output(processed_data)
    File.open(@output_file_path, 'w') do |file|
      processed_data.each do |company_id, user_list|
        file.puts "Company Id: #{company_id}"
        file.puts "Company Name: #{user_list.first[:company_name]}"
        file.puts "Users Emailed:"

        user_list.each do |user|
          if user[:email_sent]
            file.puts "\t#{user[:full_name]}, #{user[:email]}"
            file.puts "\t  Previous Token Balance, #{user[:initial_balance]}"
            file.puts "\t  New Token Balance, #{user[:updated_balance]}"
          end
        end

        file.puts "Users Not Emailed:"
        user_list.each do |user|
          unless user[:email_sent]
            file.puts "\t#{user[:full_name]}, #{user[:email]}"
            file.puts "\t  Previous Token Balance, #{user[:initial_balance]}"
            file.puts "\t  New Token Balance, #{user[:updated_balance]}"
          end
        end

        total_top_up = user_list.map { |user| user[:updated_balance] - user[:initial_balance] }.sum
        file.puts "\tTotal amount of top ups for #{user_list.first[:company_name]}: #{total_top_up}"
        file.puts
      end
    end
  rescue IOError => e
    # Handle errors related to file writing
    puts "Error writing to output file: #{e.message}"
  end

  # Writes invalid data to a separate log file
  def write_to_bad_data_log(file_path, bad_data)
    File.open(file_path, 'w') do |file|
      bad_data.each { |entry| file.puts JSON.pretty_generate(entry) }
    end
  rescue IOError => e
    # Handle errors related to log file writing
    puts "Error writing to bad data log: #{e.message}"
  end
end

# Running the processor with given file paths
users_file = 'files/users.json'
companies_file = 'files/companies.json'
output_file = 'output.txt'
bad_user_file = 'bad_users.txt'
bad_company_file = 'bad_companies.txt'

# Initialize and run the UserTopUpProcessor
processor = UserTopUpProcessor.new(users_file, companies_file, output_file, bad_user_file, bad_company_file)
processor.process