#
# Voxer Chef Formatter
#
# based on the chef `minimal` formatter
# https://github.com/opscode/chef/blob/master/lib/chef/formatters/minimal.rb
# updates include
#  - live updates as resources are updated
#  - colorized diff
#  - more verbose error messages
#  - indentation to match depth of LWRP's (`use_inline_resources`)
#  - file written to at the end with status information if `ENV['VOXER_FORMATTER_FILE']` is set
#  - syslog line generated when chef runs successfully if `ENV['VOXER_FORMATTER_SYSLOG']` is set
#
# This formatter is best used with log_level :warn
#
# Author:: Dave Eddy <dave@daveeddy.com>
# Copyright:: Copyright (c) 2007-2015, Voxer LLC
# License:: MIT
#

require 'chef/formatters/base'
require 'chef/mixin/shell_out'
require 'syslog'

include Chef::Mixin::ShellOut

class Chef
  module Formatters
    class Voxer < Formatters::Base
      cli_name :voxer

      def initialize(out, err)
        super
        @start_time = Time.now
        @root_path = Chef::Config[:root_path]

        # record resources that are updated
        @updated_resources = 0
        @updates_by_resource = Hash.new {|h, k| h[k] = []}

        # keep track of how deep we are (LWRP)
        @context_stack = []
        @context_resource = {}

        # enable color
        if Chef::Config[:color] then
          @color_red = "\e[31m"
          @color_green = "\e[32m"
          @color_magenta = "\e[35m"
          @color_reset = "\e[0m"
        else
          @color_red = ''
          @color_green = ''
          @color_magenta = ''
          @color_reset = ''
        end
      end

      # Called at the very start of a Chef Run
      def run_start(version)
        puts "starting chef in #{@root_path}, version #{version}"
      end

      # Called at the end of the Chef run.
      def run_completed(node)
        now = Time.now
        elapsed = (now - @start_time).round(2)

        gb = shell_out_wrapper(%W[git --git-dir #{@root_path}/.git rev-parse --abbrev-ref HEAD])
        gc = shell_out_wrapper(%W[git --git-dir #{@root_path}/.git rev-parse HEAD])

        data = {
          :user => ENV['SUDO_USER'] || ENV['USER'],
          :finished => now,
          :elapsed => elapsed,
          :dir => @root_path,
          :updated_resources => @updated_resources,
          :git => {
            :branch => gb,
            :commit => gc
          }
        }

        file = ENV['VOXER_FORMATTER_FILE']
        if file then
          IO.write(file, JSON.pretty_generate(data) + "\n")
        end

        if ENV['VOXER_FORMATTER_SYSLOG'] then
          @log = Syslog.open('chef', Syslog::LOG_PID, Syslog::LOG_USER)
          @log.info "chef run finished by #{data[:user]} in #{elapsed} seconds, #{@updated_resources} resources updated, branch #{gb} (#{gc})"
        end

        puts "chef client finished. #{@updated_resources} resources updated, took #{elapsed} seconds"
      end

      # called at the end of a failed run
      def run_failed(exception)
        elapsed = Time.now - @start_time
        puts "chef client failed. #{@updated_resources} resources updated, took #{elapsed} seconds"
      end

      # shell_out_wrapper to capture (stdout || stderr) and any error
      def shell_out_wrapper(args)
        o = nil
        begin
          cmd = shell_out(args)
          o = (cmd.stdout.empty? ? cmd.stderr : cmd.stdout).strip
        rescue
          o = "failed to run #{args.first}"
        end
        o
      end

      # Called right after ohai runs.
      def ohai_completed(node)
      end

      # Already have a client key, assuming this node has registered.
      def skipping_registration(node_name, config)
      end

      # About to attempt to register as +node_name+
      def registration_start(node_name, config)
      end

      def registration_completed
      end

      # Failed to register this client with the server.
      def registration_failed(node_name, exception, config)
        super
      end

      def node_load_start(node_name, config)
      end

      # Failed to load node data from the server
      def node_load_failed(node_name, exception, config)
      end

      # Default and override attrs from roles have been computed, but not yet applied.
      # Normal attrs from JSON have been added to the node.
      def node_load_completed(node, expanded_run_list, config)
      end

      # Called before the cookbook collection is fetched from the server.
      def cookbook_resolution_start(expanded_run_list)
        puts "resolving cookbooks for run list: #{expanded_run_list.inspect}"
      end

      # Called when there is an error getting the cookbook collection from the
      # server.
      def cookbook_resolution_failed(expanded_run_list, exception)
      end

      # Called when the cookbook collection is returned from the server.
      def cookbook_resolution_complete(cookbook_collection)
      end

      # Called before unneeded cookbooks are removed
      #--
      # TODO: Should be called in CookbookVersion.sync_cookbooks
      def cookbook_clean_start
      end

      # Called after the file at +path+ is removed. It may be removed if the
      # cookbook containing it was removed from the run list, or if the file was
      # removed from the cookbook.
      def removed_cookbook_file(path)
      end

      # Called when cookbook cleaning is finished.
      def cookbook_clean_complete
      end

      # Called before cookbook sync starts
      def cookbook_sync_start(cookbook_count)
        puts 'synchronizing cookbooks'
      end

      # Called when cookbook +cookbook_name+ has been sync'd
      def synchronized_cookbook(cookbook_name)
        print '.'
      end

      # Called when an individual file in a cookbook has been updated
      def updated_cookbook_file(cookbook_name, path)
      end

      # Called after all cookbooks have been sync'd.
      def cookbook_sync_complete
        puts 'done.'
      end

      # Called when cookbook loading starts.
      def library_load_start(file_count)
        puts 'compiling cookbooks'
      end

      # Called after a file in a cookbook is loaded.
      def file_loaded(path)
        print '.'
      end

      def file_load_failed(path, exception)
        puts @color_red
        puts "failed to load file --> #{path}"
        puts "                    --> #{exception}"
        puts @color_reset
        super
      end

      # Called when recipes have been loaded.
      def recipe_load_complete
        puts 'done.'
      end

      # Called before convergence starts
      def converge_start(run_context)
        puts "converging #{run_context.resource_collection.all_resources.size} resources"
      end

      # Called when the converge phase is finished.
      def converge_complete
      end

      # Called before action is executed on a resource.
      def resource_action_start(resource, action, notification_type=nil, notifier=nil)
        id = "#{resource.resource_name}[#{resource.name}]"
        rcid = resource.run_context.object_id
        @context_resource[rcid] = id

        # find out how deep we are by looking for unique run_contexts
        index = @context_stack.index rcid
        if index then
          @context_stack = @context_stack.slice(0, index + 1)
        else
          @context_stack << rcid
        end

        #puts "#{@context_stack.length} -> #{resource.resource_name}[#{resource.name}] - #{action}"
      end

      # Called when a resource fails, but will retry.
      def resource_failed_retriable(resource, action, retry_count, exception)
      end

      # Called when a resource fails and will not be retried.
      def resource_failed(resource, action, exception)
        puts @color_red
        puts "failed to handle resource --> :#{action} #{resource}"
        puts @color_reset
        puts "#{exception}"
      end

      # Called when a resource action has been skipped b/c of a conditional
      def resource_skipped(resource, action, conditional)
      end

      # Called after #load_current_resource has run.
      def resource_current_state_loaded(resource, action, current_resource)
      end

      # Called when a resource has no converge actions, e.g., it was already correct.
      def resource_up_to_date(resource, action)
      end

      ## TODO: callback for assertion failures

      ## TODO: callback for assertion fallback in why run

      # Called when a change has been made to a resource. May be called multiple
      # times per resource, e.g., a file may have its content updated, and then
      # its permissions updated.
      def resource_update_applied(resource, action, update)
        @updates_by_resource[resource.name] << update
      end

      # Called after a resource has been completely converged.
      def resource_updated(resource, action)
        @updated_resources += 1

        return if @updates_by_resource[resource.name].empty?

        indent = ''
        skip = true
        @context_stack.each do |rcid|
          name = @context_resource[rcid]

          if name then
            puts "#{indent}* #{name}"
            skip = false
          end

          @context_resource.delete rcid
          indent += '   '
        end
        return if skip

        @updates_by_resource[resource.name].each do |update|
          u = Array(update)

          # print what happened in green
          puts "#{indent}#{@color_green}  - #{u[0]}#{@color_reset}"

          if u[1].is_a?(Array) then
            # most likely a diff
            puts "#{indent}\n" + colorize_diff(u[1]).map { |l| indent + l }.join("\n")
          end
        end
        puts "#{indent}\n"
      end

      # Called before handlers run
      def handlers_start(handler_count)
      end

      # Called after an individual handler has run
      def handler_executed(handler)
      end

      # Called after all handlers have executed
      def handlers_completed
      end

      # An uncategorized message. This supports the case that a user needs to
      # pass output that doesn't fit into one of the callbacks above. Note that
      # there's no semantic information about the content or importance of the
      # message. That means that if you're using this too often, you should add a
      # callback for it.
      def msg(message)
      end

      # helper functions
      def colorize_diff(diff)
        diff.map do |l|
          f = '        '
          if l.start_with?('-') then
            f += @color_red
          elsif l.start_with?('+') then
            f += @color_green
          elsif l.start_with?('@') then
            f += @color_magenta
          end
          f += l
          f += @color_reset
          f
        end
      end
    end
  end
end
