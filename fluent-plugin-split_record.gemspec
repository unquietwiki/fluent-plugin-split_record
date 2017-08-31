# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-split_record"
  spec.version       = "0.12.1"
  spec.authors       = ["Masahiro Sano","Michael Adams"]
  spec.email         = ["sabottenda@gmail.com","unquietwiki@gmail.com"]
  spec.description   = %q{Fluentd filter plugin to split a record into multiple records with key/value pair.}
  spec.summary       = %q{Successor to original fluent-plugin-split. Updated for fluentd 0.12 and 0.14, with non-conflicting name.}
  spec.homepage      = "https://github.com/unquietwiki/fluent-plugin-split_record"
  spec.license       = "MIT"
  spec.files          = `git ls-files`.split("\n")
  spec.test_files     = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables    = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "fluentd",">= 0.12.39","< 0.16"
end
