[![Gem Version](http://img.shields.io/gem/v/active_force.svg)](http://badge.fury.io/rb/active_force)
[![Build Status](http://img.shields.io/travis/ionia-corporation/active_force.svg)](https://travis-ci.org/ionia-corporation/active_force)
[![Code Climate](http://img.shields.io/codeclimate/github/ionia-corporation/active_force.svg)](https://codeclimate.com/github/ionia-corporation/active_force)
[![Dependency Status](http://img.shields.io/gemnasium/ionia-corporation/active_force.svg)](https://gemnasium.com/ionia-corporation/active_force)
[![Test Coverage](https://codeclimate.com/github/ionia-corporation/active_force/badges/coverage.svg)](https://codeclimate.com/github/ionia-corporation/active_force)
[![Inline docs](http://inch-ci.org/github/ionia-corporation/active_force.png?branch=master)](http://inch-ci.org/github/ionia-corporation/active_force)
[![Chat](http://img.shields.io/badge/chat-gitter-brightgreen.svg)](https://gitter.im/ionia-corporation/active_force)

# ActiveForce

A ruby gem to interact with [SalesForce][1] as if it were Active Record. It
uses [Restforce][2] to interact with the API, so it is fast and stable.

## Installation

Add this line to your application's Gemfile:

    gem 'active_force'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_force

## Setup credentials

[Restforce][2] is used to interact with the API, so you will need to setup
environment variables to set up credentials.

    SALESFORCE_USERNAME       = your-email@gmail.com
    SALESFORCE_PASSWORD       = your-sfdc-password
    SALESFORCE_SECURITY_TOKEN = security-token
    SALESFORCE_CLIENT_ID      = your-client-id
    SALESFORCE_CLIENT_SECRET  = your-client-secret

You might be interested in [dotenv-rails][3] to set up those in development.

Also, you may specify which client to use as a configuration option, which is useful
when having to reauthenticate utilizing oauth.

```ruby
ActiveForce.sfdc_client = Restforce.new()
  oauth_token:         current_user.oauth_token,
  refresh_token:       current_user.refresh_token,
  instance_url:        current_user.instance_url,
  client_id:           SALESFORCE_CLIENT_ID,
  client_secret:       SALESFORCE_CLIENT_SECRET
)
```

## Usage

```ruby
class Medication < ActiveForce::SObject

  field :name,             from: 'Name'

  field :max_dossage  # defaults to "Max_Dossage__c"
  field :updated_from
 
  ##
  # You can cast field value using `as`
  # field :address_primary_active, from: 's360a__AddressPrimaryActive__c', as: :boolean
  # 
  # Available options are :boolean, :int, :double, :percent, :date, :datetime, :string, :base64, 
  # :byte, :ID, :reference, :currency, :textarea, :phone, :url, :email, :combobox, :picklist, 
  # :multipicklist, :anyType, :location

  ##
  # Table name is inferred from class name.
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

### Associations

#### Has Many

```ruby
class Account < ActiveForce::SObject
  has_many :pages

  # Use optional parameters in the declaration.

  has_many :medications,
    scoped_as: ->{ where("Discontinued__c > ? OR Discontinued__c = ?", Date.today.strftime("%Y-%m-%d"), nil) }

  has_many :today_log_entries,
    model: DailyLogEntry,
    scoped_as: ->{ where(date: Time.now.in_time_zone.strftime("%Y-%m-%d")) }

  has_many :labs,
    scoped_as: ->{ where("Category__c = 'EMR' AND Date__c <> NULL").order('Date__c DESC') }

end
```

#### Belongs to

```ruby
class Page < ActiveForce::SObject
  field :account_id,           from: 'Account__c'

  belongs_to :account
end
```

### Querying

You can retrieve SObject from the database using chained conditions to build
the query.

```ruby
Account.where(web_enable: 1, contact_by: ['web', 'email']).limit(2)
#=> this will query "SELECT Id, Name, WebEnable__c
#                    FROM Account
#                    WHERE WebEnable__C = 1 AND ContactBy__c IN ('web','email')
#                    LIMIT 2
```

It is also possible to eager load associations:

```ruby
Comment.includes(:post)
```

### Model generator

When using rails, you can generate a model with all the fields you have on your SFDC table by running:

    rails g active_force:model <table name>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new pull request so we can talk about it.
6. Once accepted, please add an entry in the CHANGELOG and rebase your changes
   to squash typos or corrections.

 [1]: http://www.salesforce.com
 [2]: https://github.com/ejholmes/restforce
 [3]: https://github.com/bkeepers/dotenv

