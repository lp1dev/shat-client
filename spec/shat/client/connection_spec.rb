require 'spec_helper'
require 'shat/client/connection'

describe Connection do
  describe '#connect' do

    context 'when the server responds positively' do
      let( :conn ){ Connection.new }

      before do
      end

      it 'returns true' do
        expect( conn.connect ).to eq( true )
      end
    end
  end
end
