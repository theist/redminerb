# Copyright (c) The Cocktail Experience S.L. (2015)
require 'erb'

module Redminerb
  # Class to render Redminerb's ERB templates
  class Template
    TEMPLATES_DIR = '.redminerb/templates'

    class << self
      # Renders the template +name+ using +resource+ assigned to a local
      # variable with that same name in its binding (i.e. the template will
      # have a local variable with the same name of the template that let
      # us access to the resource).
      #
      # ==== Parameters
      #
      # * +name+ - Filename (without the erb extension) of the template in the
      #   templates directory.
      #
      # * +resource+ - The object that will be available into the template with
      #   the same name as the the template itself.
      #
      # ==== Example:
      #
      #   # With this content in templates/issue.erb:
      #
      #   Title: <%= issue[:subject] %>
      #
      #   # ...we could call +render+ this way:
      #
      #   Redminerb::Template.render(:issue, {subject: 'Fixme!'})
      #

      def render(name, resource, options = {})
        b = binding
        b.local_variable_set(name, resource)
        template = _read_template(options['template'] || name)
        ERB.new(template).result(b)
      end

      private

      # Returns the content of the given ERB file in the templates directory.
      def _read_template(name)
        File.read(_filepath(name))
      end

      def _filepath(name)
        _localfile(name) || _homefile(name) || _gemfile(name)
      end

      def _localfile(name)
        _filepath_or_nil "#{TEMPLATES_DIR}/#{name}.erb"
      end

      def _homefile(name)
        _filepath_or_nil "#{ENV['HOME']}/#{TEMPLATES_DIR}/#{name}.erb"
      end

      def _gemfile(name)
        File.join(File.dirname(__FILE__)[0..-15], 'templates', "#{name}.erb")
      end

      def _filepath_or_nil(filepath)
        filepath if File.exist?(filepath)
      end
    end
  end
end
