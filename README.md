# Eavify

Eavify is a Rails concern that simplifies the implementation of an EAV (Entity-Attribute-Value) system. It provides dynamic attribute handling, type casting, and validations for models with different categories.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'eavify', path: 'path/to/eavify'
```

And then execute:

```bash
$ bundle install
```

## Usage

Include Eavify in your model:

```ruby
class Product < ApplicationRecord
  include Eavify

  define_eav(
    category: :electronics,
    fields: %w[brand color model price storage warranty],
    data_types: {
      "brand" => :text,
      "color" => :text,
      "model" => :text,
      "price" => :decimal,
      "storage" => :text,
      "warranty" => :text
    },
    validations: {
      presence: ["brand", "model", "price", "storage"],
      numericality: ["price"]
    }
  )
end
```

For more details, see the full documentation.
