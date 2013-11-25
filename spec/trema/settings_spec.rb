require 'trema/settings'

describe Trema::Settings, :guard => true do
  context '.new' do
    subject(:settings) { Trema::Settings.new('/tmp/foobar') }

    describe :[] do
      subject { settings[key] }

      context "with 'TREMA_HOME'" do
        let(:key) { 'TREMA_HOME' }

        it { should be_nil }
      end
    end

    describe :[]= do
      before { settings[key] = value }

      context "with 'TREMA_HOME', '/home/yasuhito'" do
        let(:key) { 'TREMA_HOME' }
        let(:value) { '/home/yasuhito' }

        its(['TREMA_HOME']) { should eq '/home/yasuhito' }
      end
    end

    context "with config 'TREMA_HOME: /home/trema'" do
      before do
        config_file = StringIO.new('TREMA_HOME: /home/trema')
        config_file.stub(:exist?).and_return(true)
        Pathname.any_instance.stub(:join).and_return(config_file)
      end

      its(['TREMA_HOME']) { should eq '/home/trema' }
    end
  end
end
