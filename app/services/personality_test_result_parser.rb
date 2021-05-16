# frozen_string_literal: true

require 'nokogiri'
require 'pry'

# app/services/personality_test_result_parser.rb
class PersonalityTestResultParser
  def initialize(name, email, options = {})
    @url = options[:url]
    @text = options[:text]
    @file = options[:file]
    @parsed_result = { NAME: name, EMAIL: email }
  end

  def call
    begin_parsing
  end

  private

  def begin_parsing
    if @text.present?
      parse_by_direct_txt(@text)
    elsif @file.try(:content_type).try(:eql?, 'text/plain')
      parse_by_file_txt(@file.path)
    elsif @file.try(:content_type).try(:eql?, 'text/html') || @url
      parse_by_file_or_url_html_doc
    end

    raise CustomException::PersonalityTest::InvalidData unless facet_data_parsed?

    @parsed_result.with_indifferent_access
  rescue CustomException::PersonalityTest::InvalidData, CustomException::PersonalityTest::InvalidUrl, SocketError => e
    { error: true, message: e.message }
  end

  def facet_data_parsed?
    !(@parsed_result.with_indifferent_access.keys - %w[NAME
                                                       EMAIL]).eql?([])
  end

  def parse_by_direct_txt(text)
    @facet_data = []

    text.split(/\n/).each do |line|
      parse_by_txt(line)
    end
    add_to_result_and_clear_data
  end

  def parse_by_file_txt(log_path)
    @facet_data = []

    IO.foreach(log_path).lazy.each do |line|
      parse_by_txt(line)
    end
    add_to_result_and_clear_data
  end

  def parse_by_txt(line)
    if line.match('Domain/Facet')
      add_to_result_and_clear_data

      return
    end

    @facet_data << parse_facet_and_value(line) if line.match(/(\.){3,}( ){0,1}\d/)
  end

  def add_to_result_and_clear_data
    @parsed_result.merge!(process_facet(@facet_data.to_h)) if @facet_data.present?
    @facet_data = []
  end

  def parse_by_file_or_url_html_doc
    if @file
      document = File.open(@file.path) { |f| Nokogiri::HTML(f) }
    else
      page = HTTParty.get(@url)
      raise CustomException::PersonalityTest::InvalidUrl unless page.response.code.eql?('200')

      document = Nokogiri::HTML(page)
    end

    parse_by_html(document)
  end

  def parse_by_html(doc)
    doc.search('.graph-txt').each do |personality_factor|
      @parsed_result.merge!(
        process_facet(
          personality_factor.try(:text).try(:strip).try(:gsub, /\t/, '').try(:split, /\n/).map do |a|
            parse_facet_and_value(a)
          end.to_h
        )
      )
    end
  end

  def process_facet(facet_data)
    processed_facet = {}
    facet_data = facet_data.reject { |k, _v| k.match('Domain/Facet') }

    facet_data_heading = facet_data.keys.first

    processed_facet[facet_data_heading] = {
      'Overall Score': facet_data[facet_data_heading],
      'Facets': {}
    }

    facet_data.delete(facet_data_heading)
    processed_facet[facet_data_heading][:Facets] = facet_data

    processed_facet.with_indifferent_access
  end

  def parse_facet_and_value(text)
    text.try(:strip).try(:gsub, /(\.)+( )*/, ',').try(:split, ',')
  end
end
