# frozen_string_literal: true

class Admin::TimeSheetsController < ApplicationController
  before_action :authenticate_user!
  def create
    start_time = Time.zone.parse(valid_params[:date].dup.insert(-1, " #{valid_params[:start_time]}"))
    end_time = Time.zone.parse(valid_params[:date].dup.insert(-1, " #{valid_params[:end_time]}"))
    options = {
      date: Date.parse(valid_params[:date]),
      start_time: start_time,
      end_time: end_time,
      duration: (end_time - start_time) / 1.minutes / 60
    }
    time_sheet = current_user.time_sheets.create(options)
    if time_sheet.persisted?
      render json: {
        timesheet: time_sheet, message: 'Your time sheet was submitted'
      }, status: :created
    end
  end

  def index; end

  private

  def valid_params
    params.require(:timesheet).permit!
  end
end
