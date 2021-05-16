# frozen_string_literal: true

require 'rails_helper'
require 'pry'

describe PersonalityTestResultParser, type: :service do
  describe '.call' do
    let(:valid_url) do
      'https://www.personalitytest.net/cgi-bin/shortipipneo3.cgi?View=86637709723860755157564&VX=VX1&VY=24&VZ=N147&Q1=5&Q2=5&Q3=5&Q4=5&Q5=5&Q6=5&Q7=5&Q8=5&Q9=1&Q10=5&Q11=5&Q12=5&Q13=5&Q14=5&Q15=5&Q16=5&Q17=5&Q18=5&Q19=1&Q20=5&Q21=5&Q22=5&Q23=5&Q24=1&Q25=5&Q26=5&Q27=5&Q28=5&Q29=5&Q30=1&Q31=5&Q32=5&Q33=5&Q34=5&Q35=5&Q36=5&Q37=5&Q38=5&Q39=1&Q40=1&Q41=5&Q42=5&Q43=5&Q44=5&Q45=5&Q46=5&Q47=5&Q48=1&Q49=1&Q50=5&Q51=5&Q52=5&Q53=5&Q54=5&Q55=5&Q56=5&Q57=5&Q58=5&Q59=5&Q60=5&Q61=5&Q62=1&Q63=5&Q64=5&Q65=5&Q66=5&Q67=1&Q68=1&Q69=1&Q70=1&Q71=5&Q72=5&Q73=1&Q74=1&Q75=1&Q76=5&Q77=5&Q78=1&Q79=1&Q80=1&Q81=1&Q82=5&Q83=1&Q84=1&Q85=1&Q86=5&Q87=5&Q88=1&Q89=1&Q90=1&Q91=5&Q92=1&Q93=5&Q94=1&Q95=5&Q96=1&Q97=1&Q98=1&Q99=1&Q100=1&Q101=1&Q102=1&Q103=1&Q104=1&Q105=1&Q106=1&Q107=1&Q108=1&Q109=1&Q110=1&Q111=1&Q112=5&Q113=1&Q114=1&Q115=1&Q116=1&Q117=5&Q118=1&Q119=1&Q120=1'
    end

    let(:invalid_url) do
      'https://www.personalitytest.net/cgi-bin/shortipipneo3.cgi'
    end

    let(:valid_text) do
      'Domain/Facet...... Score
      EXTRAVERSION.........66
      Friendliness.........47
      Gregariousness.......29
      Assertiveness........63
      Activity Level.......80
      Excitement-Seeking...76
      Cheerfulness.........76


      Domain/Facet...... Score
      AGREEABLENESS...68
      Trust...........51
      Morality........72
      Altruism........89
      Cooperation.....63
      Modesty.........26
      Sympathy........73


      Domain/Facet...... Score
      CONSCIENTIOUSNESS......65
      Self-Efficacy..........52
      Orderliness............49
      Dutifulness............78
      Achievement-Striving...76
      Self-Discipline........68
      Cautiousness...........47


      Domain/Facet...... Score
      NEUROTICISM..........76
      Anxiety..............93
      Anger................60
      Depression...........55
      Self-Consciousness...48
      Immoderation.........58
      Vulnerability........92


      Domain/Facet...... Score
      OPENNESS TO EXPERIENCE...62
      Imagination..............61
      Artistic Interests.......60
      Emotionality.............75
      Adventurousness..........48
      Intellect................37
      Liberalism...............62
      '
    end

    let(:invalid_text) do
      'jdlasfjdlksajs'
    end

    let(:personality_test_response) do
      '<div class="graph-txt">
          <code>
            <p>Domain/Facet...... Score</p>
            <p>EXTRAVERSION.........1 </p>
            <p>Friendliness.........0 </p>
            <p>Gregariousness.......1 </p>
            <p>Assertiveness........1 </p>
            <p>Activity Level.......1 </p>
            <p>Excitement-Seeking...1 </p>
            <p>Cheerfulness.........1 </p>
          </code>
        </div>
        <div class="graph-txt">
          <code>
            <p>Domain/Facet...... Score</p>
            <p>AGREEABLENESS...1 </p>
            <p>Trust...........0 </p>
            <p>Morality........1 </p>
            <p>Altruism........1 </p>
            <p>Cooperation.....1 </p>
            <p>Modesty.........1 </p>
            <p>Sympathy........1 </p>
          </code>
        </div>
        <div class="graph-txt">
          <code>
            <p>Domain/Facet...... Score</p>
            <p>CONSCIENTIOUSNESS......1 </p>
            <p>Self-Efficacy..........1 </p>
            <p>Orderliness............1 </p>
            <p>Dutifulness............1 </p>
            <p>Achievement-Striving...1 </p>
            <p>Self-Discipline........1 </p>
            <p>Cautiousness...........1 </p>
          </code>
        </div>
        <div class="graph-txt">
          <code>
            <p>Domain/Facet...... Score</p>
            <p>NEUROTICISM..........1 </p>
            <p>Anxiety..............2 </p>
            <p>Anger................1 </p>
            <p>Depression...........1 </p>
            <p>Self-Consciousness...1 </p>
            <p>Immoderation.........1 </p>
            <p>Vulnerability........1 </p>
          </code>
        </div>
        <div class="graph-txt">
          <code>
            <p>Domain/Facet...... Score</p>
            <p>OPENNESS TO EXPERIENCE...1 </p>
            <p>Imagination..............1 </p>
            <p>Artistic Interests.......1 </p>
            <p>Emotionality.............1 </p>
            <p>Adventurousness..........1 </p>
            <p>Intellect................1 </p>
            <p>Liberalism...............1 </p>
          </code>
        </div>'
    end

    it 'should return parsed data for valid url' do
      stub_request(
        :get,
        /www.personalitytest.net/
      ).to_return(
        status: 200,
        body: personality_test_response
      )

      resp = PersonalityTestResultParser.new('Test', 'test@test.com', { url: valid_url }).call
      expect(resp[:error]).not_to eq(true)
    end

    it 'should return parsed data for valid text' do
      resp = PersonalityTestResultParser.new('Test', 'test@test.com', { text: valid_text }).call
      expect(resp[:error]).not_to eq(true)
    end

    it 'should return error for invalid url' do
      stub_request(
        :get,
        /www.personalitytest.net/
      ).to_return(
        status: 500,
        body: 'Internal Server Error'
      )

      resp = PersonalityTestResultParser.new('Test', 'test@test.com', { url: invalid_url }).call
      expect(resp[:error]).to eq(true)
    end

    it 'should return error for invalid text' do
      resp = PersonalityTestResultParser.new('Test', 'test@test.com', { text: invalid_text }).call
      expect(resp[:error]).to eq(true)
    end
  end
end
