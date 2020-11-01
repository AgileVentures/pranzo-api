## ResOS

# API usage example
Documentation: https://documenter.getpostman.com/view/3308304/SzzehLGp?version=latest

```ruby
key = "OpBmGrJ5i03KBAq8pstw-4ZHX5YyyaOaGgmoV2zfcHK"
encoded_key = Base64.strict_encode64 key
table_url = "https://api.resos.com/v1/tables"
bookings_url = "https://api.resos.com/v1/bookings?fromDateTime=2020-10-30T00%3A00%3A00%2B01%3A00&toDateTime=2020-10-30T23%3A59%3A59%2B01%3A00&limit=2&skip=1"
RestClient.get(url, headers={})
```

## ResOsService

###  USAGE
#### Collection of bookings:
```ruby
ResOsService.bookings
```

#### Collection of bookings for a specific date
```ruby
ResOsService.bookings(date: '2020-12-01')
```
You can also pass in `:limit` and `:skip`.

#### Single booking:
```ruby
ResOsService.bookings(id: 'CRJE9Bbrqz2L8NbjT')
```
#### Create booking:
```ruby
ResOsService.bookings(type: :post, <pass in bookings details>)
```

#### Update booking
```ruby
ResOsService.bookings(
  type: :put,
  id: 'ip2ynBTToxvBGSdou'
  <pass in bookings details>
  )
```