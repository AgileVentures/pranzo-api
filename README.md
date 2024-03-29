# ResOS V1

## API usage example
Documentation: https://documenter.getpostman.com/view/3308304/SzzehLGp?version=latest

```ruby
key = "OpBmGrJ5i03KBAq8pstw-4ZHX5YyyaOaGgmoV2zfcHK"
encoded_key = Base64.strict_encode64 key
table_url = "https://api.resos.com/v1/tables"
bookings_url = "https://api.resos.com/v1/bookings?fromDateTime=2020-10-30T00%3A00%3A00%2B01%3A00&toDateTime=2020-10-30T23%3A59%3A59%2B01%3A00&limit=2&skip=1"
RestClient.get(url, headers={})
```

## ResOs API wrapper

### CONFIGURATION

```ruby
ResOs.configure do |config|
  config.api_key = "OpBmGrJ5i03KBAq8pstw-4ZHX5YyyaOaGgmoV2zfcHK"
end
```

###  USAGE
#### Collection of bookings:
```ruby
ResOs.bookings
```

#### Collection of bookings for a specific date
```ruby
ResOs.bookings(date: '2020-12-01')
```
You can also pass in `:limit` and `:skip`.

#### Single booking:
```ruby
ResOs.bookings(id: 'CRJE9Bbrqz2L8NbjT')
```
#### Create booking:
```ruby
ResOs.bookings(type: :post, <pass in bookings details>)
```

#### Update booking
```ruby
ResOs.bookings(
  type: :put,
  id: 'ip2ynBTToxvBGSdou'
  <pass in bookings details>
  )
```

## VOUCHER

The voucher code is generated at `create`.

A voucher must be activated (set `activated` to `true`)

```ruby
voucher = Voucher.last
doc = CardGenerator.new(voucher)
file = File.open(doc.path)
voucher.pdf_card.attach(io: file, filename: 'test.pdf')
```

## Custom Card Generator
This generator takes more options and can be configured with several templates.

There are currently 3 templates available.
```ruby
# CustomCardGenerator.new(<voucher obj>, <render:boolean/default: true>, <variant:integer>, <locale:symbol/default: :sv>)
CustomCardGenerator.new(voucher, true, 1, :sv)
```

# Formatting Emails

An interesting solution is the [MJML gem](https://github.com/sighmon/mjml-rails). A PR with good examples [can be found here](https://github.com/CraftAcademy/gigafood/pull/69)

Previewing emails: 

Halt the execution of a spec using `binding.pry`. Make sure that `current_email` is available and open the email in the browser using `current_email.save_and_open`. Preview the source of the email in the browser. Copy the source and head over to https://mjml.io/try-it-live/ to generate a preview with styling included. 

# Activity log
One way to gather data of usage, but also to track att activities of a vendor, could be to make use of [Public Activity](https://rubygems.org/gems/public_activity) gem. 

# Affiliations

The affiliation set-up is influenced by [this gist](https://gist.github.com/jibiel/5c18d36b93891cced991791529fc1686). Not sure if this the way to go, but I don't want to spend to much time onn this ;-) 

# VAT nubet lookup 
Int the MVP, the VAT lookup is done using the [ValVat gem](https://github.com/yolk/valvat). The problem with this solution is the input mechmanizm on the fronmt end. Business owners in Sweden are used to enter their identification numbers (Organisationsnummer issued by the tax Swedish Tax Agency - Skatteverket), rather than VAT-numbers. The upside is that we can go more international with this solution. Of course, only within bounds on the European Union.

# Deployement

This app is in production using [fly.io](https://fly.io/)

### COMANDS
LOGS: 
```
fly logs
```

CONSOLE: 
```
fly ssh console -C "/app/bin/rails console"
```

SWISH Payments
In order to take payments with Swidish instant payment system SWISH, we need to implement a solution based on [https://github.com/tochman/swish_api](https://github.com/tochman/swish_api)

1. Mark the vendor as able to accept swish by adding an attribute
2. Store the Vendors SWISH number
3. Display a Button for swish payment. 
4. open a form and input the customers phone number (or generate a QR code)
5. once the payment clears, activate th voucher with the customer as owner. 