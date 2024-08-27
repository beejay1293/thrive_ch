require 'rspec'
require_relative '../challenge'

RSpec.describe 'UserTopUpProcessor Integration' do
  let(:users_file) { 'spec/files/users.json' }
  let(:companies_file) { 'spec/files/companies.json' }
  let(:output_file) { 'spec/files/output.txt' }
  let(:bad_user_file) { 'spec/files/bad_users.txt' }
  let(:bad_company_file) { 'spec/files/bad_companies.txt' }

  before do
    File.write(users_file, JSON.pretty_generate([valid_user, invalid_user]))
    File.write(companies_file, JSON.pretty_generate([valid_company, invalid_company]))
  end

  after do
    File.delete(users_file) if File.exist?(users_file)
    File.delete(companies_file) if File.exist?(companies_file)
    File.delete(output_file) if File.exist?(output_file)
    File.delete(bad_user_file) if File.exist?(bad_user_file)
    File.delete(bad_company_file) if File.exist?(bad_company_file)
  end

  let(:valid_user) do
    {
      'company_id' => 1,
      'first_name' => 'John',
      'last_name' => 'Doe',
      'tokens' => 100,
      'email' => 'john.doe@example.com',
      'active_status' => true,
      'email_status' => false
    }
  end

  let(:invalid_user) do
    {
      'company_id' => nil,
      'first_name' => 'Jane',
      'last_name' => nil,
      'tokens' => 'not_a_number',
      'email' => nil,
      'active_status' => nil,
      'email_status' => 'not_a_boolean'
    }
  end

  let(:valid_company) do
    {
      'id' => 1,
      'name' => 'Tech Corp',
      'top_up' => 50,
      'email_status' => true
    }
  end

  let(:invalid_company) do
    {
      'id' => 'not_a_number',
      'name' => nil,
      'top_up' => 'not_a_number',
      'email_status' => nil
    }
  end

  it 'processes the files and generates output correctly' do
    processor = UserTopUpProcessor.new(users_file, companies_file, output_file, bad_user_file, bad_company_file)
    processor.process

    expect(File.exist?(output_file)).to be true
    expect(File.exist?(bad_user_file)).to be true
    expect(File.exist?(bad_company_file)).to be true

    output_content = File.read(output_file)
    bad_user_content = File.read(bad_user_file)
    bad_company_content = File.read(bad_company_file)

    expect(output_content).to include('Company Id: 1')
    expect(output_content).to include('Doe, John, john.doe@example.com')
    expect(output_content).to include('Previous Token Balance, 100')
    expect(output_content).to include('New Token Balance, 150')

    expect(bad_user_content).to include('Jane')
    expect(bad_company_content).to include('not_a_number')
  end
end