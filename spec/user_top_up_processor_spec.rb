require 'rspec'
require_relative '../challenge'

RSpec.describe UserTopUpProcessor do
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

  describe '#validate_companies' do
    it 'validates companies correctly' do
      processor = UserTopUpProcessor.new('', '', '', '', '')
      valid, invalid = processor.send(:validate_companies, [valid_company, invalid_company])

      expect(valid).to include(valid_company)
      expect(invalid).to include(invalid_company)
    end
  end

  describe '#validate_users' do
    it 'validates users correctly' do
      processor = UserTopUpProcessor.new('', '', '', '', '')
      company_data = { 1 => valid_company }
      valid, invalid = processor.send(:validate_users, [valid_user, invalid_user], company_data)

      expect(valid).to include(valid_user)
      expect(invalid).to include(invalid_user)
    end
  end

  describe '#process_users' do
    it 'processes users correctly' do
      processor = UserTopUpProcessor.new('', '', '', '', '')
      company_data = { 1 => valid_company }
      result = processor.send(:process_users, [valid_user], company_data)

      expect(result[1].first[:updated_balance]).to eq(150)
      expect(result[1].first[:email_sent]).to be false
    end
  end
end