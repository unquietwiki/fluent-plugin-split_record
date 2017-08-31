# fluent-plugin-split_record

Fluentd filter plugin to split a record into multiple records with key/value pair. Compatible with 0.12 and 0.14 versions of fluentd.

## Overview
This plugin splits a record and parses each results to make key/value pairs; Logstash's [kv filter](https://www.elastic.co/guide/en/logstash/current/plugins-filters-kv.html) is a good example of this. It is a successor to [fluent-plugin-split](https://github.com/kazegusuri/fluent-plugin-split/); a 0.10 output plugin. This is NOT the current 0.12+ [fluent-plugin-split](https://github.com/toyama0919/fluent-plugin-split/): that one is what currently installs with ruby-gem, and splits CSV-style content.

Normally you can use a regular expression to parse a record. It is difficult to parse a record which has ambiguous numbers of data like a following record.

**Before**
```json
{"message":"key1=val1 key2=val2 key3=val3"}
```

**After**
```json
{"key1":"val1","key2":"val2","key3":"val3"}
```

## Installation

### Local/Build
```
$ td-agent-gem build fluent-plugin-split_record.gemspec
$ td-agent-gem install fluent-plugin-split_record-0.12.1.gem
```

### Online
```
$ td-agent-gem install fluent-plugin-split_record
```

## Configuration

### Parameters

|parameter|description|default|
|---|---|---|
|tag| key name for tag | |
|format| regexp to parse a record after split | '(?<key>\S*)=(?<value>\S*)' |
|substring_format| regexp used to identify substrings | '(?<key>\S*)=\\"(?<value>.*?)\\"' |
|key_name| key name to be split | |
|out_key| key name of json object which includes divided records | nil |
|reserve_msg| if original message is reserved or not | nil |
|keys_prefix| if set, all extracted keys names will be preceded by this string | nil |

### Example

You may want to pre-process with the [regexp parser](https://docs.fluentd.org/v0.12/articles/parser_regexp) to remove/tag other elements first; this is a requirement if working with [SonicWall syslog input](http://software.sonicwall.com/manual/232-001835-00_rev_a_sonicos_log_event_reference_guide.pdf), which is otherwise an array of key-value pairs.

```
<source>
  @type udp
  port 514
  format /\<(?<prefix>[0-9]{1,3})\>(?<extradata>.+)$\z/
  tag FW
</source>

<filter FW.**>
  @type split_record
  tag SonicWall
  key_name extradata
  reserve_msg no
</filter>
```

## References

* https://github.com/repeatedly/fluent-plugin-record-modifier/
* https://docs.fluentd.org/v0.12/articles/plugin-development
* https://ruby-doc.org/core-2.1.5/
* https://stackoverflow.com/questions/tagged/ruby
* http://rubular.com/
