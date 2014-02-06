require 'bindata'

class OpenflowServiceHeader < BinData::Record
  endian :big

  uint64 :datapath_id
  uint16 :service_name_length
end
