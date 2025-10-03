module Api
  class ObservableLabelsController < ApplicationController
    def create
      if (labels = params.dig(:labels)).present?
        Setting.observable_labels = labels

        render json: { message: "Observable labels: #{Setting.observable_labels}" }, status: :created
      else
        render json: { error: "Labels are required" }, status: :unprocessable_entity
      end
    end
  end
end
