# Copyright (c) 2014 Ryan Geyer
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'net/http'

module CliRcw
  class Process < Thor
    desc "process list", "Lists processes"
    def list()
      thor_shell = Thor::Shell::Color.new
      client = RightApi::Client.new(:email => @parent_options.rs_email, :password => @parent_options.rs_pass, :account_id => @parent_options.rs_account_id)
      processes = client.cloud_flow_processes.index
      table = [
          ["Name", "GUID", "Status"]
      ]
      processes.each do |process|
        state = process.state
        color_map = {
            "running" => [process.state, :green],
            "terminated" => [process.state],
            "default" => [process.state, :red]
        }
        if color_map.key?(process.state)
          state = thor_shell.set_color(*color_map[process.state])
        else
          state = thor_shell.set_color(*color_map["default"])
        end
        table << [
            process.name,
            CliRcw::Utilities.id_from_href(process.href),
            state
        ]
      end
      thor_shell.say("Processes".center(80,'-'), :bold)
      thor_shell.print_table(table)
      thor_shell.say("End Process".center(80,'-'), :bold)
    end

    desc "process show", "Shows a process"
    def show(process_id)
      thor_shell = Thor::Shell::Color.new
      client = RightApi::Client.new(:email => @parent_options.rs_email, :password => @parent_options.rs_pass, :account_id => @parent_options.rs_account_id)
      process = client.cloud_flow_processes(:id => process_id).show()

      thor_shell.say("Process #{process_id}".center(80,'-'), :bold)
      table = [["Name",process.name]]
      table << ["GUID",process_id]
      table << ["Launched At",process.launched_at]
      table << ["Created At",process.created_at]
      table << ["Updated At",process.updated_at]
      table << ["Process Size:Max Size","#{process.process_size}:#{process.max_process_size}"]
      table << ["State",process.state]
      thor_shell.print_table(table)

      thor_shell.say("Tasks".center(80,'-'), :bold)
      task_table = [["Name", "GUID", "Position", "Execution Position", "Status"]]
      cookie_ary = []
      client.cookies.each do |key,val|
        cookie_ary << "#{key}=#{val}"
      end
      cookie_str = cookie_ary.join(";")

      url = URI.parse("#{client.api_url}#{process.links[0]["href"]}")
      puts "#{url.host}:#{url.port}#{url.path}"
      req = Net::HTTP::Get.new(url.path, {"Cookie" => cookie_str, "X_API_VERSION" => "1.5"})
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      res = http.request(req)

      #puts res.body

      #puts client.resources("cloud_flow_tasks",process.links[0]["href"].sub('tasks','cloud_flow_tasks'))
      #process.cloud_flow_tasks.each do |task|
      #  task_table << [
      #    task.name,
      #    CliRcw::Utilities.id_from_href(task.href),
      #    task.position, #"#{task.position.line},#{task.position.column}",
      #    task.execution_position, #"#{task.execution_position.line},#{task.execution_position.column}",
      #    task.state
      #  ]
      #end
      thor_shell.print_table(task_table)
      thor_shell.say("End Tasks".center(80,'-'), :bold)
      thor_shell.say("End Process #{process_id}".center(80,'-'), :bold)
    end
  end

  class Cli < Thor
    desc "process SUBCOMMAND ...ARGS", "Performs tasks on processes"
    option :rs_email, :desc => "RightScale user email address"
    option :rs_pass, :desc => "RightScale user password"
    option :rs_account_id, :desc => "RightScale account number"
    subcommand "process", Process
  end
end