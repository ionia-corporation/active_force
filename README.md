[![Gem Version](http://img.shields.io/gem/v/active_force.svg)](http://badge.fury.io/rb/active_force)
[![Build Status](http://img.shields.io/travis/ionia-corporation/active_force.svg)](https://travis-ci.org/ionia-corporation/active_force)
[![Code Climate](http://img.shields.io/codeclimate/github/ionia-corporation/active_force.svg)](https://codeclimate.com/github/ionia-corporation/active_force)
[![Dependency Status](http://img.shields.io/gemnasium/ionia-corporation/active_force.svg)](https://gemnasium.com/ionia-corporation/active_force)
[![Test Coverage](https://codeclimate.com/github/ionia-corporation/active_force/badges/coverage.svg)](https://codeclimate.com/github/ionia-corporation/active_force)
[![Chat](http://img.shields.io/badge/chat-gitter-brightgreen.svg)](https://gitter.im/ionia-corporation/active_force)

# ActiveForce

A ruby gem to interact with [SalesForce][1] as if it were Active Record. It
uses [Restforce][2] to interact with the API, so it is fast and stable.

 [1]: http://www.salesforce.com
 [2]: https://github.com/ejholmes/restforce

## Installation

Add this line to your application's Gemfile:

    gem 'active_force'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_force

If you want restforce logging on a rails app:

```ruby
#Add this to initializers/restforce.rb
Restforce.log = true if Rails.env.development?
```

## Usage

```ruby
class Medication < ActiveForce::SObject

  field :name,             from: 'Name'

  field :max_dossage  # from defaults to "Max_Dossage__c" 
  field :updated_from

  ##
  # Table name is infered from class name.
  #
  # self.table_name = 'Medication__c' # default one.

  ##
  # Validations
  #
  validates :name, :login, :email, presence: true

  # Use any validation from active record.
  # validates :text, length: { minimum: 2 }
  # validates :text, format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters" }
  # validates :size, inclusion: { in: %w(small medium large),
  #   message: "%{value} is not a valid size" }

  ##
  # Callbacks
  #
  before_save :set_as_updated_from_rails

  private

  def set_as_updated_from_rails
    self.updated_from = 'Rails'
  end

end
```

Altenative you can try the generator. (requires setting up the connection)

    rails generate active_force_model Medication__c

### Relationships

#### Has Many

```ruby
class Account < ActiveForce::SObject
  has_many :pages

  # Use option parameters in the declaration.

  has_many :medications,
    where: "Discontinued__c > #{ Date.today.strftime("%Y-%m-%d") }" \
           "OR Discontinued__c = NULL"

  has_many :today_log_entries,
    model: DailyLogEntry,
    where: { date: Time.now.in_time_zone.strftime("%Y-%m-%d") }

  has_many :labs,
    where: "Category__c = 'EMR' AND Date__c <> NULL",
    order: 'Date__c DESC'

end
```

#### Belongs to

```ruby
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
5. Create new pull request so we can talk about it.
6. Once accepted, please add an entry in the CHANGELOG and rebase your changes
   to squash typos or corrections.
