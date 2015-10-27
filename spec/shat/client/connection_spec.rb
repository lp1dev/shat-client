require 'spec_helper'
require 'shat/client/connection'

describe Connection do
  let( :config ){ Shat::Config }
  let( :server ){ double('server').as_null_object }


  describe '#connect' do

    context 'when the server responds positively' do
      let( :conn ){ Connection.new(config.remote_host, config.remote_port.to_i) }

      before do
        expect( TCPSocket ).to receive( :new ).and_return(server)
      end

      it 'returns true' do
        expect( conn.connect ).to eq( true )
      end
    end
  end
end
