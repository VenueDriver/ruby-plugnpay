require 'test_helper'
require 'ruby_plugnpay'

class Ruby_PlugNPayTest < ActiveSupport::TestCase

  # Set your PlugNPay account name or the tests will not work.
  publisher_name = 'youraccount'

  test "authorization" do
    assert PlugNPay::Service.new( 'publisher-name' => publisher_name ).
      authorize(
        'card-number' => '4111111111111111',
        'card-name' => 'cardtest',
        'card-type' => 'Visa',
        'card-amount' => '1',
        'card-exp' => '01/10')
  end

  test "authorization with bad card" do
    response = nil
    badcard = false
    begin
      response = PlugNPay::Service.new( 'publisher-name' => publisher_name ).
        authorize(
          'card-number' => '4111111111111111',
          'card-name' => 'cardtest',
          'card-type' => 'Visa',
          'card-amount' => '1500', # This amount causes a 'badcard' error.
          'card-exp' => '01/10')
    rescue PlugNPay::BadCard
      badcard = true
    end
    assert response.nil?
    assert badcard
  end

  test "authorization with problem" do
    response = nil
    problem = false
    begin
      response = PlugNPay::Service.new( 'publisher-name' => publisher_name ).
        authorize(
          'card-number' => '4111111111111111',
          'card-name' => 'cardtest',
          'card-type' => 'Visa',
          'card-amount' => '2500', # This amount causes a 'problem' error.
          'card-exp' => '01/10')
    rescue PlugNPay::Problem
      problem = true
    end
    assert response.nil?
    assert problem
  end

end
