require 'bindata'
require 'trema/message_header'
require 'trema/openflow_service_header'

class OpenFlowReady < BinData::Record
  endian :big

  message_header :message_header
  openflow_service_header :openflow_service_header
end
