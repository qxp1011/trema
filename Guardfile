# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :bundler do
  watch('Gemfile')
  # Uncomment next line if your Gemfile contains the `gemspec' command.
  watch(/^.+\.gemspec/)
end

guard :rspec do
  watch(%r{^spec/trema/.+_spec\.rb$})
  watch(%r{^ruby/trema/(.+)\.rb$})     { |m| "spec/trema/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end
