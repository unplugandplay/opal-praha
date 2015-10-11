require 'spec_helper'

class AccessingAttributesSpec < Praha::Model
  attributes :first_name, :last_name

  def last_name=(name)
    raise "Cannot set last_name"
  end
end

describe Praha::Model do

  let(:model) { AccessingAttributesSpec.new }

  describe "#[]" do
    it "retrieves attributes from the model" do
      model[:first_name].should be_nil
      model.first_name = "Adam"
      model[:first_name].should eq("Adam")
    end
  end

  describe "#[]=" do
    it "sets attributes on the model" do
      model[:first_name] = "Adam"
      model.first_name.should eq("Adam")
    end
  end
end
