# Eavify

Eavify is a Rails concern that simplifies the implementation of an EAV (Entity-Attribute-Value) system. It provides dynamic attribute handling, type casting, and validations for models with different categories.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'eavify'
```

And then execute:

```bash
$ bundle install
```

## Usage

Include Eavify in your model:

```ruby
class product < applicationrecord
  include eavify

  cfg = [

    {
      scope: :electronics,
      fields: {
        'brand' => :text,
        'color' => :text,
        'model' => :text,
        'price' => :decimal,
        'storage' => :text,
        'warranty' => :text
      },
      validations: {
        presence: %w[brand model price storage],
        numericality: ['price']
      }

    }
  ]
  define_eav cfg
end
```

For more details, see the full documentation.
