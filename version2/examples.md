---
savon_version: v2
order: 9
title: Examples
layout: guides
nav_savon_version: v2
---

## Complete request-response cycle

This example walks through a typical SOAP integration from start to finish: creating a client, discovering what operations are available, making a request, and navigating the response.

``` ruby
# Create a client from a WSDL
client = Savon.client(
  wsdl: "http://example.com/UserService?wsdl",
  pretty_print_xml: true, # logs formatted XML (useful while developing)
  log: true
)

# List available operations
client.operations
# => [:find_user, :create_user, :delete_user]

# Call an operation
response = client.call(:find_user, message: { id: 42 })

# The response body is a nested Hash with snakecase Symbol keys
response.body
# => { find_user_response: { user: { id: "42", name: "Luke", email: "luke@example.com" } } }
```

## WSSE authentication with timestamp

Many enterprise services require WS-Security credentials. If you're getting auth failures despite correct credentials, also try adding `wsse_timestamp: true`.

``` ruby
client = Savon.client(
  wsdl: "http://example.com/SecureService?wsdl",
  wsse_auth: ["username", "password", :digest],
  wsse_timestamp: true
)

response = client.call(:get_account, message: { account_id: "12345" })
account = response.body[:get_account_response][:account]
```

## Error handling

``` ruby
def find_user(id)
  response = client.call(:find_user, message: { id: id })
  response.body[:find_user_response][:user]
rescue Savon::SOAPFault => error
  fault = error.to_hash[:fault]
  raise "Service error #{fault[:faultcode]}: #{fault[:faultstring]}"
rescue Savon::HTTPError => error
  raise "HTTP #{error.http.code}"
end
```

## Key conversion

By default, symbol keys are converted to lowerCamelCase XML tags. You can change this globally with `convert_request_keys_to`.

``` ruby
# Default: :lower_camelcase
# :user_id => <userId>
client.call(:find_user, message: { user_id: 42 })

# :camelcase - use when the service expects UpperCamelCase element names
# :user_id => <UserId>
client = Savon.client(wsdl: "...", convert_request_keys_to: :camelcase)

# :upcase - use when the service expects UPPER_CASE element names
# :user_id => <USER_ID>
client = Savon.client(wsdl: "...", convert_request_keys_to: :upcase)

# :none - symbols are output as-is, no conversion applied
# :user_id => <user_id>
client = Savon.client(wsdl: "...", convert_request_keys_to: :none)

# String keys always bypass conversion regardless of the convert_request_keys_to setting
# 'UserId' => <UserId> even with the default :lower_camelcase in effect
client.call(:find_user, message: { "UserId" => 42 })
```

## Nested message structures

Nested hashes map to nested XML elements. This is the standard way to build structured SOAP messages.

``` ruby
response = client.call(:create_order, message: {
  order: {
    customer_id: "CUST-042",
    shipping_address: {
      street: "1428 Elm St",
      city:   "Springfield",
      zip:    "12345"
    },
    notes: "Leave at door"
  }
})
```

## Arrays in messages

Pass an array as a value to produce repeated XML elements.

``` ruby
# Produces: <id>1</id><id>2</id><id>3</id> inside <userIds>
response = client.call(:find_users, message: {
  user_ids: { id: [1, 2, 3] }
})
```

## Navigating a nested response

SOAP responses are typically deeply nested. Use Ruby's `dig` to reach the value you need.

``` ruby
response = client.call(:get_order, message: { order_id: "ORD-001" })

response.body
# => {
#      get_order_response: {
#        order: {
#          id:     "ORD-001",
#          status: "shipped",
#          items:  {
#            item: [
#              { name: "Widget", qty: "2" },
#              { name: "Gadget", qty: "1" }
#            ]
#          }
#        }
#      }
#    }

order = response.body.dig(:get_order_response, :order)
order[:status]                       # => "shipped"
order.dig(:items, :item, 0, :name)   # => "Widget"
```

## Handling errors without raising

By default Savon raises on SOAP faults. Set `raise_errors: false` to handle them yourself.

``` ruby
client = Savon.client(wsdl: "...", raise_errors: false)

response = client.call(:find_user, message: { id: 99 })

if response.soap_fault?
  fault = response.body[:fault]
  puts "#{fault[:faultcode]}: #{fault[:faultstring]}"
elsif response.http_error?
  puts "HTTP #{response.http.code}"
else
  response.body[:find_user_response][:user]
end
```

## Filtering sensitive values from logs

When logging is enabled, use `filters` to redact sensitive values from the output.

``` ruby
client = Savon.client(
  wsdl: "...",
  log: true,
  filters: [:password, :credit_card_number, :ssn]
)
# Filtered values appear as ***FILTERED*** in the log output
```

## Session cookies

Some services authenticate via a first call and then require the session cookie on subsequent requests.

``` ruby
auth_response = client.call(:login, message: { username: "luke", password: "secret" })
cookies = auth_response.http.cookies

client.call(:find_user, message: { id: 42 }, cookies: cookies)
```

## Without a WSDL

When no WSDL is available, provide the endpoint and namespace manually. You will also need to set `soap_action` per request.

``` ruby
client = Savon.client(
  endpoint: "https://service.example.com/users",
  namespace: "http://v1.example.com/users"
)

client.call(:find_user,
  soap_action: "http://v1.example.com/users/FindUser",
  message: { user_id: 42 }
)
```
