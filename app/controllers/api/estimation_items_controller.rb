module Api
  class EstimationItemsController < ApplicationController
    def create
      reference_url = params[:reference_url]
      emails = params[:emails]

      if reference_url.blank? || emails.blank?
        render json: { error: "Reference URL and emails are required" }, status: :unprocessable_entity
        return
      end

      ActiveRecord::Base.transaction do
        service = EstimationItems::Service.new
        estimation_item = service.create_estimation_item(reference_url, emails)
        service.send_estimations(estimation_item)

        render json: estimation_item, status: :created
      end
    end

    def send_results
      estimation_item = EstimationItem.find(params[:id])
      EstimationItems::Service.new.send_results(estimation_item)

      render json: { message: "Results sent successfully" }, status: :ok
    end
  end
end
