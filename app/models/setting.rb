class Setting < RailsSettings::Base
  field :observable_labels, default: ["Need QA", "Need Improvements", "Need Rebase"], type: :array
  field :estimation_marks,
    default: ["less than an hour", "1", "2", "3", "4", "6", "8", "10", "12", "can't estimate"],
    type: :array,
    validates: { length: { maximum: 10 } } # slack limit
end
