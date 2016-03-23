# BqFactory

[![Build Status](https://travis-ci.org/yuemori/bq_factory.svg?branch=master)](https://travis-ci.org/yuemori/bq_factory)

This gem create Static SQL View on Google Bigquery from Hash and Array with DSL.

Inspired by [bq_fake_view](https://github.com/joker1007/bq_fake_view)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bq_factory'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bq_factory

## Usage

### Configuration

Add configuration to initializer or spec_helper.

```ruby
# RSpec
# spec/spec_helper.rb

BqFactory.configure do |config|
  config.project_id = 'google_project_id'
  config.keyfile_path = '/path/to/keyfile.json' # from google developer console
end
```

### specify schema

This pattern is fetch schema from hash(not call api access).

First, setup factories in fixture file:

```ruby
BqFactory.register :user, dataset: :test_dataset, schema: [{ name: 'name', type: 'INTEGER' }, { name: 'age', type: 'INTEGER' }]
```

And, In your test code:

```
describe 'test query' do
  before(:all) do
    BqFactory.create_dataset!(:test_dataset)
  end

  describe 'query is valid' do
    before { BqFactory.create_view(:test_dataset, :test_view, users) }
    subject { BqFactory.query(query) }

    let(:users) { [{ name: 'alice', age: 20 }] }
    let(:query) { 'SELECT * FROM [test_dataset.test_view]' }

    it { expect(subject.first).to eq users.first }
  end
end
```

### fetch schema from bigquery

This pattern is fetch schema from bigquery(call api access).

First, setup factories in fixture file:

```ruby
# Reference target of dataset and tables in options.
# Factory fetch schema from  bigquery
BqFactory.register :user, dataset: 'my_dataset' # => reference my_dataset.user table
BqFactory.register :user, dataset: 'my_dataset', table: 'my_table' # => reference my_dataset.my_table
```

If register `:user, dataset: 'test_dataset'` and `user` table schema is this:

|column_name|type|
|:----|:----|
|name|STRING|
|age|INTEGER|
|create_at|TIMESTAMP|
|height|FLOAT|
|admin|BOOLEAN|

And, In your test code:

```ruby
# RSpec

describe 'query test' do
  before(:all) do
    BqFactory.create_dataset!('test_dataset') # => create test dataset
  end
  let(:alice) { { name: 'alice', age: 20, create_at: "2016-01-01 00:00:00", height: 150.1, admin: true } }
  let(:bob) { { name: 'bob', age: 30, create_at: "2016-01-01 00:00:00", height: 170.1, admin: false } }

  describe 'build query' do
    subject { BqFactory.build_query :user, alice }
    let(:query) { 'SELECT * FROM (SELECT "alice" AS name, 20 AS age, TIMESTAMP("2016-01-01 00:00:00") AS create_at, 150.1 AS height, true AS admin )' }
    it { is_expected.to eq query }
  end

  describe 'from Hash' do
    before { BqFactory.create_view :test_dataset, :test_view1, alice }
    # => Build query 'SELECT * FROM (SELECT "alice" AS name, 20 AS age, TIMESTAMP("2016-01-01 00:00:00") AS create_at, 150.1 AS height, true AS admin )'
    # And create view "test_view" to "test_dataset"

    let(:query) { "SELECT * FROM [test_dataset.test_view]" }
    subject { BqFactory.query(query) }

    it { expect(subject.first).to eq alice
  end

  describe 'from Array' do
    before { BqFactory.create_view :test_dataset, :test_view2, [alice, bob] }
    # => Build query 'SELECT * FROM (SELECT "alice" AS name, 20 AS age, TIMESTAMP("2016-01-01 00:00:00") AS create_at, 150.1 AS height, true AS admin ), (SELECT "bob" AS name, 30 AS age, TIMESTAMP("2016-01-01 00:00:00") AS create_at, 170.1 AS height, false AS admafterin)'
    # And create view "test_view" to "test_dataset"

    let(:query) { "SELECT * FROM [test_dataset.test_view]" }
    subject { BqFactory.query(query) }

    it { expect(subject.first).to eq alise }
    it { expect(subject.last).to eq bob }
  end

  after(:all) do
    BqFactory.delete_dataset!('test_dataset') # => clean up!
  end
end
```

## Testing

### Install dependencies

```shell
$ bundle install
```

### Run rspec

```shell
$ bundle exec rspec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/bq_factory. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

