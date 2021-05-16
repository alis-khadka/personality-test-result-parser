# frozen_string_literal: true

require 'rails_helper'
require 'pry'

describe RecruitbotApi, type: :service do
  describe '.call' do
    let(:valid_parsed_result) do
      {
        "NAME": 'Test',
        "EMAIL": 'test@test.com',
        "EXTRAVERSION": {
          "Overall Score": '66',
          "Facets": {
            "Friendliness": '47',
            "Gregariousness": '29',
            "Assertiveness": '63',
            "Activity Level": '80',
            "Excitement-Seeking": '76',
            "Cheerfulness": '76'
          }
        },
        "AGREEABLENESS": {
          "Overall Score": '68',
          "Facets": {
            "Trust": '51',
            "Morality": '72',
            "Altruism": '89',
            "Cooperation": '63',
            "Modesty": '26',
            "Sympathy": '73'
          }
        },
        "CONSCIENTIOUSNESS": {
          "Overall Score": '65',
          "Facets": {
            "Self-Efficacy": '52',
            "Orderliness": '49',
            "Dutifulness": '78',
            "Achievement-Striving": '76',
            "Self-Discipline": '68',
            "Cautiousness": '47'
          }
        },
        "NEUROTICISM": {
          "Overall Score": '76',
          "Facets": {
            "Anxiety": '93',
            "Anger": '60',
            "Depression": '55',
            "Self-Consciousness": '48',
            "Immoderation": '58',
            "Vulnerability": '92'
          }
        },
        "OPENNESS TO EXPERIENCE": {
          "Overall Score": '62',
          "Facets": {
            "Imagination": '61',
            "Artistic Interests": '60',
            "Emotionality": '75',
            "Adventurousness": '48',
            "Intellect": '37',
            "Liberalism": '62'
          }
        }
      }.with_indifferent_access
    end

    let(:invalid_parsed_result) do
      valid_parsed_result.merge({ 'EMAIL': 'used@test.com' })
    end

    it 'should return token for valid parsed result' do
      stub_request(
        :post,
        %r{recruitbot.trikeapps.com/api/v1/roles/bellroy-tech-team-recruit/big_five_profile_submissions}
      ).to_return(
        status: 201,
        body: 'test token'
      )

      resp = RecruitbotApi.new(valid_parsed_result).call
      expect(resp[:status_code]).to eq('201')
    end

    it 'should return error message for invalid parsed result' do
      stub_request(
        :post,
        %r{recruitbot.trikeapps.com/api/v1/roles/bellroy-tech-team-recruit/big_five_profile_submissions}
      ).to_return(
        status: 422,
        body: 'Email has already been taken.'
      )

      resp = RecruitbotApi.new(invalid_parsed_result).call
      expect(resp[:status_code]).to eq('422')
    end
  end
end
