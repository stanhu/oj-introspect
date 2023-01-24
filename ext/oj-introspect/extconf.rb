require "mkmf"
require "pathname"
require "oj"

oj_version_file = Oj.const_source_location(:VERSION).first
oj_version_file_path = Pathname.new(oj_version_file)

OJ_HEADERS = oj_version_file_path.join('..', '..', '..', 'ext', 'oj').to_s

cc_version = `#{RbConfig.expand("$(CC) --version".dup)}`
if cc_version.match?(/clang/i)
  # Ignore symbols loaded from Oj in case Ruby is compiled without
  # "-Wl,-undefined,dynamic_lookup" (related to https://bugs.ruby-lang.org/issues/19005)
  symfile = File.join(__dir__, 'oj.sym')
  dynamic_symbols = File.readlines(symfile)
  dynamic_symbols.each do |sym|
    $DLDFLAGS << " -Wl,-U,#{sym.strip}"
  end

  # Needed for Ruby 3.2 ABI check: https://github.com/ruby/ruby/pull/5474
  if RUBY_VERSION >= "3.2" && RUBY_PATCHLEVEL < 0
    $LDFLAGS << " -Wl,-exported_symbol,_ruby_abi_version"
  end
end

dir_config('oj', [OJ_HEADERS], [])

create_makefile("oj/introspect/introspect_ext")
