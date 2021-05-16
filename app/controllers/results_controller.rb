# frozen_string_literal: true

# app/controllers/results_controller.rb
class ResultsController < ApplicationController
  before_action :check_params, only: :show_result

  def index; end

  def show_result
    set_parsed_result

    if @parsed_result[:error]
      flash[:error] = @parsed_result[:message]
      redirect_to results_path
    end

    # Storing in session
    session[:parsed_result] = @parsed_result
  end

  def verify_result
    @parsed_result = session[:parsed_result]
    # Clearing the data in session
    session.delete(:parsed_result)

    @recruitbot_api_resp = RecruitbotApi.new(@parsed_result).call
  end

  private

  def result_params
    params.permit(
      :name,
      :email,
      :upload,
      :text,
      :url
    )
  end

  def check_params
    raise CustomException::CompulsoryParamMissing unless compulsory_param_available?

    check_data_param_validity
    url_valid if result_params[:url].present?
  rescue CustomException::CompulsoryParamMissing, CustomException::DataParamMissing, CustomException::OnlyOneDataParamAllowed,
         CustomException::NotPersonalityUrl => e
    flash[:error] = e.message
    redirect_to results_path
  end

  def url_valid
    raise CustomException::NotPersonalityUrl unless result_params[:url].match(%r{https://www.personalitytest.net/cgi-bin/shortipipneo3.cgi}).present?
  end

  def check_data_param_validity
    raise CustomException::DataParamMissing unless data_param_available?

    raise CustomException::OnlyOneDataParamAllowed if multiple_data_param?
  end

  def compulsory_param_available?
    (result_params[:name].present? || result_params[:email].present?)
  end

  def data_param_available?
    (result_params[:upload].present? || result_params[:text].present? || result_params[:url].present?)
  end

  def multiple_data_param?
    ((
      result_params[:upload].present? &&
      (result_params[:text].present? || result_params[:url].present?)
    ) ||
      (
        result_params[:text].present? && result_params[:url].present?)
    )
  end

  def set_parsed_result
    @parsed_result = PersonalityTestResultParser.new(
      result_params[:name],
      result_params[:email],
      {
        file: result_params[:upload],
        text: result_params[:text],
        url: result_params[:url]
      }
    ).call
  end
end
