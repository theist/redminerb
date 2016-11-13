# Copyright (c) The Cocktail Experience S.L. (2015)
require_relative '../time_entries'

module Redminerb
  module Cli
    # 'users' Thor subcommand definition
    class TimeEntries < Thor
      default_command :list
  
      desc 'list', 'Shows the time entries in Redmine.'
      option :fields, aliases: :f, banner: 'id:issue_id:hours:comments'
      option :name,   aliases: [:q, '--query'], banner: '<FILTER>'
      option :offset, aliases: :o
      option :limit, aliases: :l
      option :all, type: :boolean,
                   desc: "List all the users at the database. Internally it makes\n" +
                     <<-DESC
                                 # as many HTTP requests to the REST API as needed. The
                                 # --limit option says to redminerb the maximum number of
                                 # users it should get with each request. To search consider
                                 # using the --query option instead (if possible).
                     DESC

      def list
        Redminerb.init!
        require "pry"; binding.pry
        fields = options.delete(:fields) || 'id:issue_id:hours:comments'
        Redminerb::TimeEntries.list(options).each do |time_entry|
          puts fields.split(':').map {|f| time_entry.send(f)}.join("\t").green
        end
      end
 
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      # (i'd move code from here but inheriting from Thor i still don't know how :(
      desc 'add', 'Adds a time entry.'
      option :ask,        type: :boolean, default: true
      option :issue_id,   aliases: [:i, '--issue-id']
      option :spent_on,   aliases: [:s, '--spent-on']
      option :hours,      aliases: [:h, '--hours']
      option :activit_id, aliases: [:a, '--activity']
      option :comments,   aliases: [:c, '--comments']
      def create
        Redminerb.init!
        if options[:ask]
          loop do
            initializer_data = @_initializer.detect do |internal|
              internal.is_a?(Hash) && internal.keys.include?(:current_command)
            end
            initializer_data[:current_command].options.keys.each do |option|
              next if option == :ask
              value = ask("#{option.capitalize} [#{options[option]}]:",
                          Thor::Shell::Color::GREEN)
              options[option] = value unless value.empty?
            end
            break if yes?('Is everything OK? (NO/yes)')
          end
        end
        puts Redminerb::TimeEntries.create(options).green
      end
      # rubocop:enabled Metrics/AbcSize, Metrics/MethodLength

      desc 'show <id>', 'Shows a user (SHORTCUT: "redminerb users <id>").'
      option :template, aliases: :t
      def show(user_id)
        Redminerb.init!
        puts Redminerb::Template.render(:user, Redminerb::Users.read(user_id), options)
      end
    end
  end
end
