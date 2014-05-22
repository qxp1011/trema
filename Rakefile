# encoding: utf-8
#
# Copyright (C) 2008-2013 NEC Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/ruby'))

require 'rake'
require 'trema/executables'
require 'trema/path'

task :default => :build_trema

directory Trema.log
directory Trema.pid
directory Trema.sock

desc 'Build Trema'
task :build_trema => [
  Trema.log,
  Trema.pid,
  Trema.sock,
  :management_commands,
  :rubylib,
  :switch_manager,
  :switch_daemon,
  :packetin_filter,
  :tremashark,
  :vendor,
  :examples
]

require 'paper_house'
require 'trema/version'

CFLAGS = [
  '-g',
  '-std=gnu99',
  '-D_GNU_SOURCE',
  '-fno-strict-aliasing',
  '-Wall',
  '-Wextra',
  '-Wformat=2',
  '-Wcast-qual',
  '-Wcast-align',
  '-Wwrite-strings',
  '-Wconversion',
  '-Wfloat-equal',
  '-Wpointer-arith'
]
CFLAGS << '-Werror' if RUBY_VERSION < '1.9.0'

desc 'Build Trema C library (static library).'
task 'libtrema:static' => 'vendor:openflow'
PaperHouse::StaticLibraryTask.new 'libtrema:static' do | task |
  task.library_name = 'libtrema'
  task.target_directory = Trema.lib
  task.sources = "#{ Trema.include }/*.c"
  task.cflags = CFLAGS
  task.includes = [Trema.openflow]
end

desc 'Build Trema C library (coverage).'
task 'libtrema:gcov' => ['vendor:openflow']
PaperHouse::StaticLibraryTask.new 'libtrema:gcov' do | task |
  task.library_name = 'libtrema'
  task.target_directory = "#{ Trema.home }/objects/unittests"
  task.sources = "#{ Trema.include }/*.c"
  task.includes = [Trema.openflow]
  task.cflags = ['--coverage'] + CFLAGS
end

desc 'Build Trema C library (shared library).'
task 'libtrema:shared' => 'vendor:openflow'
PaperHouse::SharedLibraryTask.new 'libtrema:shared' do | task |
  task.library_name = 'libtrema'
  task.target_directory = Trema.lib
  task.version = Trema::VERSION
  task.sources = "#{ Trema.include }/*.c"
  task.includes = [Trema.openflow]
  task.cflags = CFLAGS
end

desc 'Build Trema Ruby library.'
task 'rubylib' => 'libtrema:static'
PaperHouse::RubyExtensionTask.new 'rubylib' do | task |
  task.library_name = 'trema'
  task.target_directory = Trema.ruby
  task.sources = "#{ Trema.ruby }/trema/*.c"
  task.includes = [Trema.include, Trema.openflow]
  task.cflags = CFLAGS
  task.ldflags = ['-Wl,-Bsymbolic', "-L#{ Trema.lib }"]
  task.library_dependencies = %w(trema sqlite3 pthread rt dl crypt m)
end

desc 'Build switch manager.'
task :switch_manager => 'libtrema:static'

PaperHouse::ExecutableTask.new :switch_manager do | task |
  task.target_directory = File.dirname(Trema::Executables.switch_manager)
  task.sources = [
    'src/switch_manager/dpid_table.c',
    'src/switch_manager/event_forward_entry_manipulation.c',
    'src/switch_manager/secure_channel_listener.c',
    'src/switch_manager/switch_manager.c',
    'src/switch_manager/switch_option.c'
  ]
  task.includes = [Trema.include, Trema.openflow]
  task.cflags = CFLAGS
  task.ldflags = "-L#{ Trema.lib }"
  task.library_dependencies = %w(trema sqlite3 pthread rt dl)
end

desc 'Build switch daemon.'
task :switch_daemon => 'libtrema:static'

PaperHouse::ExecutableTask.new :switch_daemon do | task |
  task.executable_name = File.basename(Trema::Executables.switch)
  task.target_directory = File.dirname(Trema::Executables.switch)
  task.sources = [
    'src/switch_manager/cookie_table.c',
    'src/switch_manager/event_forward_entry_manipulation.c',
    'src/switch_manager/ofpmsg_recv.c',
    'src/switch_manager/ofpmsg_send.c',
    'src/switch_manager/secure_channel_receiver.c',
    'src/switch_manager/secure_channel_sender.c',
    'src/switch_manager/service_interface.c',
    'src/switch_manager/switch.c',
    'src/switch_manager/switch_option.c',
    'src/switch_manager/xid_table.c'
  ]
  task.includes = [Trema.include, Trema.openflow]
  task.cflags = CFLAGS
  task.ldflags = "-L#{ Trema.lib }"
  task.library_dependencies = %w(trema sqlite3 pthread rt dl)
end

################################################################################
# Extract OpenFlow reference implementation
################################################################################

task 'vendor:openflow' => Trema.openflow_h
file Trema.openflow_h => Trema.objects do
  sh "tar xzf #{ Trema.vendor_openflow }.tar.gz -C #{ Trema.vendor }"
  cp_r "#{ Trema.vendor_openflow }/include/openflow", Trema.objects
end
directory Trema.objects

CLOBBER.include(Trema.vendor_openflow) if FileTest.exists?(Trema.vendor_openflow)
CLOBBER.include(File.join(Trema.objects, 'openflow')) if FileTest.exists?(File.join(Trema.objects, 'openflow'))

################################################################################
# Build phost
################################################################################

task 'vendor:phost' => [Trema::Executables.phost, Trema::Executables.cli]

def phost_src
  File.join Trema.vendor_phost, 'src'
end

def phost_objects
  FileList[ File.join(phost_src, '*.o')]
end

def phost_vendor_binary
  File.join phost_src, 'phost'
end

def phost_cli_vendor_binary
  File.join phost_src, 'cli'
end

def phost_clean_targets
  ( phost_objects + [phost_vendor_binary, phost_cli_vendor_binary]).select do | each |
    FileTest.exists? each
  end
end

file Trema::Executables.phost do
  cd phost_src do
    sh 'make'
  end
  mkdir_p File.dirname(Trema::Executables.phost)
  install File.join(phost_src, 'phost'), Trema::Executables.phost, :mode => 0755
end

file Trema::Executables.cli do
  cd phost_src do
    sh 'make'
  end
  mkdir_p File.dirname(Trema::Executables.cli)
  install File.join(phost_src, 'cli'), Trema::Executables.cli, :mode => 0755
end

CLEAN.include phost_clean_targets
CLOBBER.include(Trema.phost) if FileTest.exists?(Trema.phost)

################################################################################
# Build vendor/*
################################################################################

task :vendor => [
  'vendor:oflops',
  'vendor:openflow',
  'vendor:phost'
]

################################################################################
# Build packetin filter
################################################################################

desc 'Build packetin filter.'
task :packetin_filter => 'libtrema:static'

PaperHouse::ExecutableTask.new :packetin_filter do | task |
  task.executable_name = File.basename(Trema::Executables.packetin_filter)
  task.target_directory = File.dirname(Trema::Executables.packetin_filter)
  task.sources = ['src/packetin_filter/*.c']
  task.includes = [Trema.include, Trema.openflow]
  task.cflags = CFLAGS
  task.ldflags = "-L#{ Trema.lib }"
  task.library_dependencies = %w(trema sqlite3 pthread rt dl)
end

################################################################################
# Build oflops
################################################################################

def cbench_command
  File.join Trema.objects, 'oflops/bin/cbench'
end

task 'vendor:oflops' => cbench_command
file cbench_command => Trema.openflow_h do
  sh "tar xzf #{ Trema.vendor_oflops }.tar.gz -C #{ Trema.vendor }"
  cd Trema.vendor_oflops do
    sh "./configure --prefix=#{ Trema.oflops } --with-openflow-src-dir=#{ Trema.vendor_openflow }"
    sh 'make install'
  end
end

CLEAN.include(Trema.oflops) if FileTest.exists?(Trema.oflops)
CLOBBER.include(Trema.vendor_oflops) if FileTest.exists?(Trema.vendor_oflops)

################################################################################
# cmockery
################################################################################

task 'vendor:cmockery' => Trema.libcmockery_a
file Trema.libcmockery_a do
  sh "tar xzf #{ Trema.vendor_cmockery }.tar.gz -C #{ Trema.vendor }"
  cd Trema.vendor_cmockery do
    sh "./configure --disable-shared --prefix=#{ Trema.cmockery }"
    sh 'make install'
  end
end

CLEAN.include(Trema.vendor_cmockery) if FileTest.exists?(Trema.vendor_cmockery)
CLOBBER.include(Trema.cmockery) if FileTest.exists?(Trema.cmockery)

################################################################################
# Build examples
################################################################################

$standalone_examples = %w(cbench_switch dumper learning_switch list_switches multi_learning_switch packet_in repeater_hub switch_info switch_monitor traffic_monitor)

desc 'Build examples.'
task :examples =>
  $standalone_examples.map { | each | "examples:#{ each }" } +
  [
    'examples:openflow_switch',
    'examples:openflow_message',
    'examples:switch_event_config',
    'examples:packetin_filter_config'
  ]

$standalone_examples.each do | each |
  name = "examples:#{ each }"

  task name => 'libtrema:static'
  PaperHouse::ExecutableTask.new name do | task |
    task.executable_name = each
    task.target_directory = File.join(Trema.objects, 'examples', each)
    task.sources = ["src/examples/#{ each }/*.c"]
    task.includes = [Trema.include, Trema.openflow]
    task.cflags = CFLAGS
    task.ldflags = "-L#{ Trema.lib }"
    task.library_dependencies = %w(trema sqlite3 pthread rt dl)
  end
end

################################################################################
# Build openflow switches
################################################################################

$openflow_switches = %w(hello_switch echo_switch)

task 'examples:openflow_switch' => $openflow_switches.map { | each | "examples:openflow_switch:#{ each }" }

$openflow_switches.each do | each |
  name = "examples:openflow_switch:#{ each }"

  task name => 'libtrema:static'
  PaperHouse::ExecutableTask.new name do | task |
    task.executable_name = each
    task.target_directory = File.join(Trema.objects, 'examples', 'openflow_switch')
    task.sources = ["src/examples/openflow_switch/#{ each }.c"]
    task.includes = [Trema.include, Trema.openflow]
    task.cflags = CFLAGS
    task.ldflags = "-L#{ Trema.lib }"
    task.library_dependencies = %w(trema sqlite3 pthread rt dl)
  end
end

################################################################################
# Build openflow messages
################################################################################

$openflow_messages = %w(echo features_request hello set_config vendor_action)

task 'examples:openflow_message' => $openflow_messages.map { | each | "examples:openflow_message:#{ each }" }

$openflow_messages.each do | each |
  name = "examples:openflow_message:#{ each }"

  task name => 'libtrema:static'
  PaperHouse::ExecutableTask.new name do | task |
    task.executable_name = each
    task.target_directory = File.join(Trema.objects, 'examples', 'openflow_message')
    task.sources = ["src/examples/openflow_message/#{ each }.c"]
    task.includes = [Trema.include, Trema.openflow]
    task.cflags = CFLAGS
    task.ldflags = "-L#{ Trema.lib }"
    task.library_dependencies = %w(trema sqlite3 pthread rt dl)
  end
end

###############################################################################
# Build switch_event_config
###############################################################################

$switch_event_config = %w(add_forward_entry delete_forward_entry set_forward_entries dump_forward_entries)

task 'examples:switch_event_config' => $switch_event_config.map { | each | "examples:switch_event_config:#{ each }" }

$switch_event_config.each do | each |
  name = "examples:switch_event_config:#{ each }"

  task name => 'libtrema:static'
  PaperHouse::ExecutableTask.new name do | task |
    task.executable_name = each
    task.target_directory = File.join(Trema.objects, 'examples', 'switch_event_config')
    task.sources = ["src/examples/switch_event_config/#{ each }.c"]
    task.includes = [Trema.include, Trema.openflow]
    task.cflags = CFLAGS
    task.ldflags = "-L#{ Trema.lib }"
    task.library_dependencies = %w(trema sqlite3 pthread rt dl)
  end
end

################################################################################
# Build packetin_filter_config
################################################################################

$packetin_filter_config = %w(add_filter delete_filter delete_filter_strict dump_filter dump_filter_strict)

task 'examples:packetin_filter_config' => $packetin_filter_config.map { | each | "examples:packetin_filter_config:#{ each }" }

$packetin_filter_config.each do | each |
  name = "examples:packetin_filter_config:#{ each }"

  task name => 'libtrema:static'
  PaperHouse::ExecutableTask.new name do | task |
    task.executable_name = each
    task.target_directory = File.join(Trema.objects, 'examples', 'packetin_filter_config')
    task.sources = ["src/examples/packetin_filter_config/#{ each }.c", 'src/examples/packetin_filter_config/utils.c']
    task.includes = [Trema.include, Trema.openflow]
    task.cflags = CFLAGS
    task.ldflags = "-L#{ Trema.lib }"
    task.library_dependencies = %w(trema sqlite3 pthread rt dl)
  end
end

################################################################################
# Build management commands
################################################################################

$management_commands = %w(application echo set_logging_level show_stats)

desc 'Build management commands.'
task :management_commands => $management_commands.map { | each | "management:#{ each }" }

$management_commands.each do | each |
  name = "management:#{ each }"

  task name => 'libtrema:static'
  PaperHouse::ExecutableTask.new name do | task |
    task.executable_name = each
    task.target_directory = File.join(Trema.objects, 'management')
    task.sources = ["src/management/#{ each }.c"]
    task.includes = [Trema.include, Trema.openflow]
    task.cflags = CFLAGS
    task.ldflags = "-L#{ Trema.lib }"
    task.library_dependencies = %w(trema sqlite3 pthread rt dl)
  end
end

################################################################################
# Tremashark
################################################################################

desc 'Build tremashark.'
task :tremashark => [:packet_capture, :syslog_relay, :stdin_relay, :openflow_wireshark_plugin, 'libtrema:static']

PaperHouse::ExecutableTask.new :tremashark do | task |
  task.executable_name = File.basename(Trema::Executables.tremashark)
  task.target_directory = File.dirname(Trema::Executables.tremashark)
  task.sources = [
    'src/tremashark/pcap_queue.c',
    'src/tremashark/queue.c',
    'src/tremashark/tremashark.c'
                 ]
  task.includes = [Trema.include, Trema.openflow]
  task.cflags = CFLAGS
  task.ldflags = "-L#{ Trema.lib }"
  task.library_dependencies = %w(trema sqlite3 pthread rt dl pcap)
end

task :packet_capture => 'libtrema:static'

PaperHouse::ExecutableTask.new :packet_capture do | task |
  task.executable_name = File.basename(Trema::Executables.packet_capture)
  task.target_directory = File.dirname(Trema::Executables.packet_capture)
  task.sources = [
    'src/tremashark/packet_capture.c',
    'src/tremashark/queue.c'
                 ]
  task.includes = [Trema.include, Trema.openflow]
  task.cflags = CFLAGS
  task.ldflags = "-L#{ Trema.lib }"
  task.library_dependencies = %w(trema sqlite3 pthread rt dl pcap)
end

task :syslog_relay => 'libtrema:static'

PaperHouse::ExecutableTask.new :syslog_relay do | task |
  task.executable_name = File.basename(Trema::Executables.syslog_relay)
  task.target_directory = File.dirname(Trema::Executables.syslog_relay)
  task.sources = ['src/tremashark/syslog_relay.c']
  task.includes = [Trema.include, Trema.openflow]
  task.cflags = CFLAGS
  task.ldflags = "-L#{ Trema.lib }"
  task.library_dependencies = %w(trema sqlite3 pthread rt dl pcap)
end

task :stdin_relay => 'libtrema:static'

PaperHouse::ExecutableTask.new :stdin_relay do | task |
  task.executable_name = File.basename(Trema::Executables.stdin_relay)
  task.target_directory = File.dirname(Trema::Executables.stdin_relay)
  task.sources = ['src/tremashark/stdin_relay.c']
  task.includes = [Trema.include, Trema.openflow]
  task.cflags = CFLAGS
  task.ldflags = "-L#{ Trema.lib }"
  task.library_dependencies = %w(trema sqlite3 pthread rt dl pcap)
end

$packet_openflow_so = File.join(Trema.vendor_openflow_git, 'utilities', 'wireshark_dissectors', 'openflow', 'packet-openflow.so')
$wireshark_plugins_dir = File.join(File.expand_path('~'), '.wireshark', 'plugins')
$wireshark_plugin = File.join($wireshark_plugins_dir, File.basename($packet_openflow_so))

file $packet_openflow_so do
  sh "tar xzf #{ Trema.vendor_openflow_git }.tar.gz -C #{ Trema.vendor }"
  cd File.dirname($packet_openflow_so) do
    sh 'make'
  end
end

file $wireshark_plugin => [$packet_openflow_so, $wireshark_plugins_dir] do
  cp $packet_openflow_so, $wireshark_plugins_dir
end

directory $wireshark_plugins_dir

task :openflow_wireshark_plugin => $wireshark_plugin

CLEAN.include(Trema.vendor_openflow_git) if FileTest.exists?(Trema.vendor_openflow_git)

################################################################################
# Maintenance Tasks
################################################################################

begin
  require 'bundler/gem_tasks'
rescue LoadError
  $stderr.puts $ERROR_INFO.to_s
end

################################################################################
# Relish
################################################################################

task :relish do
  sh 'relish push trema/trema'
end

################################################################################
# C Unit tests.
################################################################################

def libtrema_unit_tests
  {
    :byteorder_test => [:log, :utility, :wrapper, :trema_wrapper],
    :daemon_test => [:log, :utility, :wrapper, :trema_wrapper],
    :ether_test => [:buffer, :log, :utility, :wrapper, :trema_wrapper],
    :external_callback_test => [],
    :messenger_test => [:doubly_linked_list, :hash_table, :event_handler, :linked_list, :utility, :wrapper, :timer, :log, :trema_wrapper],
    :openflow_application_interface_test => [:buffer, :byteorder, :hash_table, :doubly_linked_list, :linked_list, :log, :openflow_message, :packet_info, :stat, :trema_wrapper, :utility, :wrapper],
    :openflow_message_test => [:buffer, :byteorder, :linked_list, :log, :packet_info, :utility, :wrapper, :trema_wrapper],
    :packet_info_test => [:buffer, :log, :utility, :wrapper, :trema_wrapper],
    :stat_test => [:hash_table, :doubly_linked_list, :log, :utility, :wrapper, :trema_wrapper],
    :timer_test => [:log, :utility, :wrapper, :doubly_linked_list, :trema_wrapper],
    :trema_test => [:utility, :log, :wrapper, :doubly_linked_list, :trema_private, :trema_wrapper]
  }
end

def test_c_files(test)
  names = [test.to_s.gsub(/_test$/, '')] + libtrema_unit_tests[ test]
  names.collect do | each |
    if each == :buffer
      ['src/lib/buffer.c', 'unittests/buffer_stubs.c']
    elsif each == :wrapper
      ['src/lib/wrapper.c', 'unittests/wrapper_stubs.c']
    else
      "src/lib/#{ each }.c"
    end
  end.flatten
end

directory 'objects/unittests'

task :build_old_unittests => libtrema_unit_tests.keys.map { | each | "unittests:#{ each }" }

libtrema_unit_tests.keys.each do | each |
  PaperHouse::ExecutableTask.new "unittests:#{ each }" do | task |
    name = "unittests:#{ each }"
    task name => ['vendor:cmockery', 'vendor:openflow', 'objects/unittests']

    task.executable_name = each.to_s
    task.target_directory = File.join(Trema.home, 'unittests/objects')
    task.sources = test_c_files(each) + ["unittests/lib/#{ each }.c"]
    task.includes = [Trema.include, Trema.openflow, File.dirname(Trema.cmockery_h), 'unittests']
    task.cflags = ['-DUNIT_TESTING', '--coverage', CFLAGS]
    task.ldflags = "-DUNIT_TESTING -L#{ File.dirname Trema.libcmockery_a } --coverage"
    task.library_dependencies = %w(cmockery sqlite3 pthread rt dl pcap)
  end
end

# new unittest
$tests = [
  'objects/unittests/buffer_test',
  'objects/unittests/doubly_linked_list_test',
  'objects/unittests/ether_test',
  'objects/unittests/event_forward_interface_test',
  'objects/unittests/hash_table_test',
  'objects/unittests/linked_list_test',
  'objects/unittests/log_test',
  'objects/unittests/packetin_filter_interface_test',
  'objects/unittests/packet_info_test',
  'objects/unittests/packet_parser_test',
  'objects/unittests/persistent_storage_test',
  'objects/unittests/trema_private_test',
  'objects/unittests/utility_test',
  'objects/unittests/wrapper_test',
  'objects/unittests/match_table_test',
  'objects/unittests/message_queue_test',
  'objects/unittests/management_interface_test',
  'objects/unittests/management_service_interface_test'
         ]

task :build_unittests => $tests.map { | each | 'unittests:' + File.basename(each) }

$tests.each do |each|
  test = File.basename(each)

  task "unittests:#{test}" => ['libtrema:gcov', 'vendor:cmockery']
  PaperHouse::ExecutableTask.new "unittests:#{test}" do |task|
    task.executable_name = test.to_s
    task.target_directory = File.join(Trema.home, 'unittests/objects')
    task.sources = ["unittests/lib/#{test}.c", 'unittests/cmockery_trema.c']
    task.includes = [Trema.include, Trema.openflow, File.dirname(Trema.cmockery_h), 'unittests']
    task.cflags = ['--coverage', CFLAGS]
    task.ldflags = "-L#{ File.dirname Trema.libcmockery_a } -Lobjects/unittests --coverage"
    task.library_dependencies = %w(trema cmockery sqlite3 pthread rt dl)
  end
end

desc 'Run unittests'
task :unittests => [:build_old_unittests, :build_unittests] do
  Dir.glob('unittests/objects/*_test').each do | each |
    puts "Running #{ each }..."
    sh each
  end
end

################################################################################
# TODO, FIXME etc.
################################################################################

desc 'Print list of notes.'
task :notes do
  keywords = %w(TODO FIXME XXX)
  keywords.each do | each |
    system "find src unittests -name '*.c' | xargs grep -n #{ each }"
    system "find ruby spec features -name '*.rb' | xargs grep -n #{ each }"
  end
end

Dir.glob('tasks/*.rake').each { |each| import each }
