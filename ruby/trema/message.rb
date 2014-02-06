require 'bindata'
require 'trema/message_header'
require 'trema/openflow_service_header'
require 'trema/message_context'

MESSAGE_TYPE_NOTIFY = 0
MESSAGE_TYPE_REQUEST = 1
MESSAGE_TYPE_REPLY = 2

class Message < BinData::Record
  endian :big

  message_header :header
  choice(:data,
         :read_length => lambda { header.message_length - header.num_bytes },
         :selection => lambda { header.message_type },
         :choices => {
           MESSAGE_TYPE_NOTIFY => :openflow_service_header,
           MESSAGE_TYPE_REQUEST => :message_context
         })

  def message_type
    header.message_type
  end

  def datapath_id
    data.datapath_id
  end

  def transaction_id
    data.transaction_id
  end

  def service_name
    data.service_name
  end
end
