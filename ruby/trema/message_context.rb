require 'bindata'

class MessageContext < BinData::Record
  endian :big

  uint32 :transaction_id
  uint16 :service_name_length
  uint16 :padding
  stringz :service_name, :read_length => :service_name_length
end
