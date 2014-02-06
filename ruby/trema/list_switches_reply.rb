require 'bindata'
require 'trema/message_header'

class ListSwitchesReply < BinData::Record
  endian :big

  message_header :header

  uint32 :transaction_id
  uint16 :service_name_length, :value => 0
  uint16 :padding, :value => 0
  array :dpids, :type => :uint64, :initial_length => 0
end

