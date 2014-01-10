require 'open-uri'

module Slices
  module Tasks

    class PageHtml
      attr_accessor :body

      def initialize(host, path)
        document = open('http://' + host + path)
        self.body = document.present? ? document.read : nil
        self.body.gsub!(/\?[0-9]{10}/, '') # remove cache busting
      rescue OpenURI::HTTPError
      end

      def ==(other)
        body == other.body
      end

      def temp_path
        write_to_tempfile unless @tempfile
        @tempfile.path
      end

      private

      def write_to_tempfile
        @tempfile = Tempfile.new('html').tap do |file|
          file << body
          file.flush
        end
      end

    end

    def self.validate(local, remote)
      hosts = [local, remote]
      Page.all.each do |page|
        puts page.path
        a, b = hosts.map do |host|
          PageHtml.new(host, page.path)
        end
        if a != b
          puts `diff #{a.temp_path} #{b.temp_path}`
          puts ''
        end
      end

    end
  end
end

namespace :slices do

  desc "Validate localhost is the same is live"
  task valdiate: :environment do
    remote = ENV['HOST']
    local = ENV.include?('LOCAL') ? ENV['LOCAL'] : 'localhost:3000'
    Slices::Tasks.validate(remote, local)
  end
end

