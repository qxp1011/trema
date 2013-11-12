Feature: "Packet In" sample application

  In order to learn how to handle Packet In messages
  As a developer using Trema
  I want to execute "Packet In" sample application

  Background:
    Given the current example directory is "packet_in"
    And a file named "packet_in.conf" with:
      """
      vswitch("packet_in") { dpid 0xabc }

      vhost("host1")
      vhost("host2")

      link "packet_in", "host1"
      link "packet_in", "host2"
      """

  @slow_process
  Scenario: Run the C example
    Given I compile "packet_in.c" into "packet_in"
    And I run `trema run ./packet_in -c packet_in.conf -d`
    And wait until "packet_in" is up
    When I send 1 packet from host1 to host2
    And *** sleep 1 ***
    Then the file "tmp/log/packet_in.log" should contain "received a packet_in"

  @slow_process
  Scenario: Run the Ruby example
    Given I run `trema run packet-in.rb -c packet_in.conf -d`
    And wait until "PacketInDumper" is up
    When I send 1 packet from host1 to host2
    And *** sleep 1 ***
    Then the file "tmp/log/PacketInDumper.log" should contain "received a packet_in"
