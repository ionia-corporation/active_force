[![Gem Version](http://img.shields.io/gem/v/active_force.svg)](http://badge.fury.io/rb/active_force)
[![Build Status](http://img.shields.io/travis/ionia-corporation/active_force.svg)](https://travis-ci.org/ionia-corporation/active_force)
[![Code Climate](http://img.shields.io/codeclimate/github/ionia-corporation/active_force.svg)](https://codeclimate.com/github/ionia-corporation/active_force)
[![Dependency Status](http://img.shields.io/gemnasium/ionia-corporation/active_force.svg)](https://gemnasium.com/ionia-corporation/active_force)
[![Test Coverage](https://codeclimate.com/github/ionia-corporation/active_force/badges/coverage.svg)](https://codeclimate.com/github/ionia-corporation/active_force)


# ActiveForce

A ruby gem to interact with SalesForce as if it were Active Record. It
uses Restforce to interact with the API, so it is fast and stable.

## Installation

Add this line to your application's Gemfile:

    gem 'active_force'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_force

Rails:

```ruby
#Add this to initializers/restforce.rb
Restforce.log = true if Rails.env.development?
::Client = Restforce.new
```

## Usage

### Define a class

```ruby
class Page < ActiveForce::SObject

end
```

### Add Attributes
```ruby
class Page < ActiveForce::SObject
  #field, :attribute_name, from: 'Name_In_Salesforce_Database'
  field :id,                from: 'Id'
  field :name,              from: 'Medication__c'
  self.fields     = mappings.values
  #set SalesForce table name.
  self.table_name = 'Patient_Medication__c'
end
```
### Validations
You can use any validation that active record has (except for validates_associated), just by adding them to your class:

```ruby
validates :name, :login, :email, presence: true
validates :text, length: { minimum: 2 }
validates :text, format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters" }
validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} is not a valid size" }
```

### Relationships

#### Has Many

```ruby
class Account < ActiveForce::SObject
  has_many :pages
end

class Page < ActiveForce::SObject
  field :account_id,           from: 'Account__c'
end
```

you could send a option parameter in the declaration.

```ruby
class Account < ActiveForce::SObject
  has_many :medications,
    where: "(Date_Discontinued__c > #{ Date.today.strftime("%Y-%m-%d") } or Date_Discontinued__c = NULL)"

  has_many :today_log_entrys,
    model: DailyLogEntry,
    where: "Date__c = #{ Time.now.in_time_zone.strftime("%Y-%m-%d") }"

  has_many :labs,
    where: "Category__c = 'EMR' And Date__c <> NULL",
    order: 'Date__c DESC'
end
```

#### Belongs to
```ruby
class Account < ActiveForce::SObject
end

class Page < ActiveForce::SObject
  field :account_id,           from: 'Account__c'
  belongs_to :account
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
