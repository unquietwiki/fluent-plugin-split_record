# Derived from https://github.com/kazegusuri/fluent-plugin-split/blob/master/lib/fluent/plugin/out_split.rb
# Aug 30, 2017; Michael Adams; unquietwiki@gmail.com

# References
# https://github.com/repeatedly/fluent-plugin-record-modifier/
# https://docs.fluentd.org/v0.12/articles/plugin-development
# https://ruby-doc.org/core-2.1.5/
# https://stackoverflow.com/questions/tagged/ruby

require 'fluent/filter'

module Fluent
  class SplitRecordFilter < Filter
    Fluent::Plugin.register_filter("split_record", self)

    # Parameters
    config_param :tag, :string
    config_param :key_name, :string
    config_param :out_key, :string, :default => nil
    config_param :reserve_msg, :bool, :default => nil
    config_param :keys_prefix, :string, :default => nil
    config_param :format, :string, :default => '(?<key>\S*)=(?<value>\S*)'
    config_param :substring_format, :string, :default => '(?<key>\S*)=\\"(?<value>.*?)\\"'
    
    # Configuration
    def configure(conf)
      super
      @format_regex = Regexp.new(@format)
      @format_regex_substring = Regexp.new(@substring_format)
      unless @format_regex.names.include?("key") and @format_regex.names.include?("value")
          raise ConfigError, "split_record: format must have named_captures of key and value"
      end
      if (!keys_prefix.nil? && keys_prefix.is_a?(String))
        @store_fun = method(:store_with_prefix)
      else
        @store_fun = method(:store)
      end
    end

    # ===== Required API methods =====
    def start
      super
    end

    def shutdown
      super
    end

    def filter(tag, time, record)
      record
    end

    def filter_stream(tag, es)
      mes = MultiEventStream.new
      es.each { |time, record|
        begin
          msg = record[@key_name]
          record.delete(@key_name) unless @reserve_msg
          data = split_message(msg)
          if @out_key.nil?
            record.merge!(data)
          else
            record[@out_key] = data
          end
          mes.add(time, record)
        rescue => e
          router.emit_error_event(tag, time, record, e)
        end
      }
      mes
    end

    # ===== Private methods =====
    private

    # Message splitter
    def split_message(message)
      return {} unless message.is_a?(String)
      # Convert key-pairs as found
      if @format_regex_substring.nil?
        key_values = message.scan @format_regex
      # Pop off substrings; get their key-pairs; then scan the leftovers
      else
        key_values = message.scan @format_regex_substring
        leftovers = message.gsub(@format_regex_substring,'').scan(@format_regex)
        leftovers.each { |e| key_values << e }
      end
      # Store key pairs
      data = {}
      key_values.each { |e| @store_fun.call(data,e[0],e[1]) }
      data
    end

    # Store key/value pair
    def store(data, key, value)
      data.store(key, value)
    end

    # Store key/value pair, with prefix
    def store_with_prefix(data, key, value)
      data.store(@keys_prefix+key, value)
    end

  end
end