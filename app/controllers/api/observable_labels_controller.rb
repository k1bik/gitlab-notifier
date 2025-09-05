module Api
  class ObservableLabelsController < ApplicationController
    def create
      labels = params.dig(:labels)

      if labels.blank?
        render json: { error: "Labels are required" }, status: :unprocessable_entity
        return
      end

      labels.each do |label|
        observable_label = ObservableLabel.find_or_initialize_by(name: label)
        observable_label.save!
      end

      render json: { message: "Observable labels created" }, status: :created
    end

    def destroy
      observable_label = ObservableLabel.find_by!(name: params[:name])

      observable_label.destroy!

      render json: { message: "Observable label destroyed" }, status: :ok
    end
  end
end
