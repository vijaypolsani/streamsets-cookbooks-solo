# Pulled logic from Couchbase cookbook
# https://github.com/disney/couchbase/blob/441064912f4781b658b9c16c67e8b4a03f480f21/libraries/helper.rb

require 'chef/mixin/shell_out'
require "net/http"

module StreamsetsHelpers

  class Server
    extend Chef::Mixin::ShellOut

    def self.service_listening?(port)
      netstat_command = "netstat -lnt"
      cmd = shell_out!(netstat_command)
      Chef::Log.debug("`#{netstat_command}` returned: \n\n #{cmd.stdout}")
      cmd.stdout.each_line.select do |l|
        l.split[3] =~ /#{port}/
      end.any?
    end

    def self.endpoint_responding?(uri)
      response = Net::HTTP.get_response(uri)
      if response.kind_of?(Net::HTTPSuccess) || response.kind_of?(Net::HTTPRedirection) || response.kind_of?(Net::HTTPForbidden)
        Chef::Log.debug("GET to #{uri} successful")
        return true
      else
        Chef::Log.debug("GET to #{uri} returned #{response.code} / #{response.class}")
        return false
      end

    rescue EOFError, Errno::ECONNREFUSED
      Chef::Log.debug("GET to #{uri} returned EOFError or Errno::ECONNREFUSED")
      return false
    end
  end

end

