# frozen_string_literal: true

require_relative "lib/eavify/version"

Gem::Specification.new do |spec|
  spec.name = "eavify"
  spec.version = Eavify::VERSION
  spec.authors = ["bugloper"]
  spec.email = ["bugloper@gmail.com"]

  spec.summary = "Dynamic PostgreSQL columns using Entity-Attributes-Value model with JSONB"
  spec.description = "Eavify provides a lightweight solution for adding dynamic columns to PostgreSQL " \
                     "using the Entity-Attributes-Value (EAV) model with JSONB support for ActiveRecord. " \
                     "Easily create flexible schemas with minimal performance overhead."
  spec.homepage = "https://github.com/bugloper/eavify"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "activerecord", ">= 6.1.0"
  spec.add_dependency "pg", ">= 1.2.0"

  spec.add_development_dependency "minitest", "~> 5.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "~> 1.36"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
