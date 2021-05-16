# frozen_string_literal: true

require 'nokogiri'
require 'pry'

# app/services/recruitbot_api.rb
class RecruitbotApi
  def initialize(parsed_result = {})
    @parsed_result = parsed_result
    @url = 'https://recruitbot.trikeapps.com/api/v1/roles/bellroy-tech-team-recruit/big_five_profile_submissions'
  end

  def call
    submit_result
  end

  private

  def submit_result
    recruitbot_api_response = HTTParty.post(
      @url,
      body: @parsed_result.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    response = { status_code: recruitbot_api_response.response.code }
    if response[:status_code] == '201'
      response[:token] = recruitbot_api_response.body
    else
      response[:message] = recruitbot_api_response.body
    end

    response
  end
end
