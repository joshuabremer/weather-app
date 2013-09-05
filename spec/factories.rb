FactoryGirl.define do
  # Car with no attributes
  factory :empty_code, class: Code do
    
  end

  factory :valid_code, class: Code do
    random_code = Faker::Lorem.words(1).to_s.capitalize
    code_text random_code
  end

end