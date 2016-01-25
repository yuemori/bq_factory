guard :rspec, cmd: 'bundle exec rspec'  do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)/(.+)\.rb$}) { |m| "spec/#{m[1]}/#{m[2]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { 'spec' }
end

guard :rubocop, all_on_start: false, cli: ['--format', 'clang', '--display-cop-names'], cmd: 'bundle exec rubocop', notification: true do
  watch(%r{.+\.rb$})
  watch(%r{.+\.rake$})
  watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
end
