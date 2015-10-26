require 'rails_helper'

describe Vote do
  describe "validations" do
    describe "value validation" do

      before do
        @vote_ok1 = Vote.new(value: 1)
        @vote_ok2 = Vote.new(value: -1)
        @vote_not_ok = Vote.new(value: 2)
      end

      it "only allows -1 or 1 as values" do
        expect( @vote_ok1.valid? ).to eq true
        expect( @vote_ok2.valid? ).to eq true
        expect( @vote_not_ok.valid? ).to eq false
      end
    end
  end
end
