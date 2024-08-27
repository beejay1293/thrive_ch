# thrive_ch

# Ruby Token Top-Up Script

This Ruby script processes JSON files containing user and company data, top-ups user tokens based on the user's status and company settings, and generates an output file summarizing the results.

## Features

- **Token Top-Up**: Automatically top-ups tokens for active users based on the company's specified top-up amount.
- **Email Notification Simulation**: Indicates whether an email would have been sent to the user based on both the user's and company's email settings.
- **Validation & Logging**: Validates both user and company data, processing only valid entries and logging any bad data for further investigation.
- **Ordered Output**: Companies are ordered by `company_id`, and users are ordered alphabetically by their last names in the output.
- **Error Handling**: Handles various edge cases, including bad data and file read/write errors.

## Prerequisites

- Ruby installed on your machine (preferably via Homebrew).
  
  You can install Ruby using Homebrew with the following command:
  ```bash
  brew install ruby
  ```

- JSON files containing user and company data (`users.json` and `companies.json`).

## Setup and Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/beejay1293/thrive_ch.git
   cd thrive_ch
   ```

2. **Place JSON Files**:
   Ensure that `users.json` and `companies.json` are placed in the `files` directory.

3. **Run the Script**:
   Execute the Ruby script from the command line:
   ```bash
   ruby challenge.rb
   ```

4. **Run Tests:**:
   Execute the test suite using RSpec:
   ```bash
   rspec
   ```

5. **Check Output**:
   After running the script, an `output.txt` file will be generated in the root directory, containing the processed data. Additionally, `bad_users.txt` and `bad_companies.txt` will be created to log any bad data encountered during processing.

## Example Usage

### Input:
- `files/users.json`: Contains user data, including their company association, active status, and email settings.
- `files/companies.json`: Contains company data, including token top-up amount and email settings.

### Output:
- `output.txt`: A detailed summary of the token top-ups, organized by company and user. Includes whether an email would have been sent based on the email status.
- `bad_users.txt`: A log of any users that could not be processed due to bad data. Includes the bad data.
- `bad_companies.txt`: A log of any companies that could not be processed due to bad data. Includes the bad data.

#### Sample Output Structure:

```
Company Id: 2
Company Name: Yellow Mouse Inc.
Users Emailed:
	Boberson, Bob, bob.boberson@test.com
	  Previous Token Balance, 23
	  New Token Balance, 60
	Boberson, John, john.boberson@test.com
	  Previous Token Balance, 15
	  New Token Balance, 52
	Nichols, Tanya, tanya.nichols@test.com
	  Previous Token Balance, 23
	  New Token Balance, 23
	Simpson, Edgar, edgar.simpson@notreal.com
	  Previous Token Balance, 67
	  New Token Balance, 104
	Simpson, Natalie, natalie.simpson@test.com
	  Previous Token Balance, 89
	  New Token Balance, 89
Users Not Emailed:
	Gordon, Sara, sara.gordon@test.com
	  Previous Token Balance, 22
	  New Token Balance, 59
	Weaver, Sebastian, sebastian.weaver@fake.com
	  Previous Token Balance, 66
	  New Token Balance, 103
	Total amount of top ups for Yellow Mouse Inc.: 185
```

## Error Handling

- **File Not Found**: If the script can't find `users.json` or `companies.json`, it will output an error message.
- **JSON Parsing Error**: If the JSON files are improperly formatted, the script will notify you.
- **Bad Data**: The script checks for required fields in both user and company records and handles any missing or incorrect data gracefully, logging bad data to separate files (`bad_users.txt` and `bad_companies.txt`).

## Code Structure

- **`challenge.rb`**: Main script that handles reading input files, processing data, and writing the output file.
- **`files/users.json`**: Input file containing user data.
- **`files/companies.json`**: Input file containing company data.
- **`output.txt`**: Generated file that contains the results after running the script.
- **`bad_users.txt`**: Generated file that contains the logs of bad user data entries after running the script.
- **`bad_companies.txt`**: Generated file that contains the logs of bad company data entries after running the script.

