require "spec_helper"
describe Code do

  it "should not have an empty code value" do
    code = Code.new()
    code.valid?.should be false
  end

  it "should have a unique code value" do
    random_code = Faker::Lorem.words(1).to_s.capitalize
    Code.create(:code_text => random_code)
    code = Code.create(:code_text => random_code)
    code.valid?.should be false

  end

  it "should default to unredeemed" do
    
    code = FactoryGirl.build(:valid_code)
    code.redeemed.should be false

  end

  it "should set the redeemed to false when it is redeemed" do
    code = FactoryGirl.build(:valid_code)
    code.redeem()
    code.redeemed.should be true

  end

  it "should set the redeemed_at to right now when it is redeemed" do
    code = FactoryGirl.build(:valid_code)
    code.redeem()
    code.redeemed_at.to_i.should be Time.now.to_i

  end






  # it "should generate a random identifier on creation" do
  #   car = FactoryGirl.build(:defined_car)
  #   car.save
  #   car.code.should_not == nil
  # end
  # it "should be retrievable by email" do
  #   ApplicationMailer.should_receive(:lost_car)
  #   FactoryGirl.create(:defined_car)
  #   Car.lost('email@email.com')
  # end
  # it "should recognize when it's registered to more than one email" do
  #   ApplicationMailer.should_receive(:lost_cars)
  #   FactoryGirl.create(:defined_car)
  #   FactoryGirl.create(:defined_car)
  #   Car.lost('email@email.com')
  # end
  # it "should respond to locations" do
  #   car = FactoryGirl.build(:empty_car)
  #   car.should respond_to(:locations)
  # end
  # it "should be locatable" do
  #   car = FactoryGirl.create(:car_with_locations)
  #   car.locate.should be_instance_of(Location)
  # end
  # it "should notify if no locations" do
  #   car = FactoryGirl.create(:defined_car)
  #   car.locate.should == "No Locations"
  # end
  # it "should return newest location" do
  #   car = FactoryGirl.create(:car_with_locations)
  #   location = car.locate
  #   location.created_at.should be > car.locations[3].created_at
  # end
end