# frozen_string_literal: true

require_relative 'lib/uk_bank_holidays/version'

Gem::Specification.new do |spec|
  spec.name = 'uk_bank_holidays'
  spec.version = UKBankHolidays::VERSION
  spec.authors = ['Matt']
  spec.email = ['jetnova@pm.me']

  spec.summary = 'Something minto'
  spec.description = 'Sooooooooooo minto.'
  spec.homepage = "https://www.github.com/m-smiff/#{spec.name}"
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'documentation_uri' => "https://www.rubydoc.info/github/m-smiff/#{spec.name}/main",
    'changelog_uri' => "#{spec.homepage}/blob/main/CHANGELOG.md",
    'source_code_uri' => spec.homepage,
    'rubygems_mfa_required' => 'true'
  }

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines('\x0', chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '~> 7.0'
end
