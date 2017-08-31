require 'fluent/test'
require 'fluent/plugin/filter_split_record'

class SplitRecordFilterTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    type split_record
    tag foo.filtered
    key_name message
  ]

  def create_driver(conf = CONFIG, tag='test')
    Fluent::Test:::OutputTestDriver.new(Fluent::SplitRecordFilter, tag).configure(conf)
  end

  def get_hostname
    require 'socket'
    Socket.gethostname.chomp
  end

  def test_configure
    assert_raise(Fluent::ConfigError) {
      create_driver(CONFIG + %[
        format /aa/
      ])
    }
    assert_raise(Fluent::ConfigError) {
      create_driver(CONFIG + %[
        format (?<key>a)
      ])
    }
    assert_raise(Fluent::ConfigError) {
      create_driver(CONFIG + %[
        format (?<value>a)
      ])
    }
    assert_nothing_raised(Fluent::ConfigError) {
      create_driver(CONFIG + %[
        format (?<value>a) (?<key>b)
      ])
    }
  end

  def test_format_1
    d = create_driver

    d.run do
      d.emit({"message" => "key1=val1 key2=val2"})
      d.emit({"message" => " key1=val1 "})
      d.emit({"message" => " "})
      d.emit({"message" => 1})
    end

    mapped = {'gen_host' => get_hostname, 'foo' => 'bar', 'included_tag' => 'test'}
    assert_equal [
      {"key1" => "val1", "key2" => "val2"},
      {"key1" => "val1"},
      {},
      {},
    ], d.records
  end

  def test_format_2
    d = create_driver(CONFIG + %[
      separator ,
      reserve_msg true
    ])

    d.run do
      d.emit({"message" => "key1=val1,key2=val2"})
    end

    assert_equal [
      {"message" => "key1=val1,key2=val2", "key1" => "val1", "key2" => "val2"},
    ], d.records
  end
  
  def test_format_3
    d = create_driver(CONFIG + %[
      out_key data
    ])

    d.run do
      d.emit({"message" => "key1=val1 key2=val2"})
    end

    assert_equal [
      {"data" => {"key1" => "val1", "key2" => "val2"}},
    ], d.records
  end

  def test_format_keysprefix
    d = create_driver(CONFIG + %[
      out_key data
      keys_prefix extracted_
    ])

    d.run do
      d.emit({"message" => "key1=val1 key2=val2"})
    end

    assert_equal [
      {"data" => {"extracted_key1" => "val1", "extracted_key2" => "val2"}},
    ], d.records
  end
end
