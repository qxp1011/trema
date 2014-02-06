require 'bindata'

class MessageHeader < BinData::Record
  endian :big

  uint8 :version, :initial_value => 0
  uint8 :message_type
  uint16 :tag
  uint32 :message_length
end
