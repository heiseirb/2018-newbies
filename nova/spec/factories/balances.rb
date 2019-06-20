# frozen_string_literal: true

FactoryBot.define do
  factory :balance do
    user { create(:user) }
    amount { 1000 }
  end
end
