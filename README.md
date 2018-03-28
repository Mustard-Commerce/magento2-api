# Magento2::Api

Simple ruby wrapper to use Magento 2 rest api / integration from ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'magento2-api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install magento2-api

## Usage

### 1. Setup integration in Magento 2

Before you can access the Magento 2 API, you need to setup a new integration in your shop as follows:

* Go to *System > Integrations* and click "Add New Integration"
* Go to API and select the API's you want to be usable for this integration
* Provide a name and click save
* Click on "activate" in the list of integrations and then "Allow"
* Write down "Consumer Key", "Consumer Secret", "Access Token" and "Access Token Secret"

### 2. Access API via ruby

Initialize the API with the credentials you got before. Additionally, set the host where Magento 2 runs.
```ruby
Magento2::Api.configure(consumer_key, consumer_secret, access_token, access_token_secret, "https://www.example.com")
```

Now you can use the api. Check out <http://devdocs.magento.com/swagger/index_20.html> for information about the data formats.

#### GET
```
Magento2::Api.get("/rest/#{locale}/V1/products/#{sku}")
```

#### POST
```POST
Magento2::Api.post("/rest/#{locale}/V1/products", { product: body })
```

#### PUT
```PUT
Magento2::Api.put("/rest/#{locale}/V1/products/#{sku}", { product: body })
```

#### DELETE
```DELETE
Magento2::Api.delete("/rest/de/V1/products/#{id}" )
```

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/antiloopgmbh/magento2-api>.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
