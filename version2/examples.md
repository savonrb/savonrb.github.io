---
savon_version: v2
order: 8
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
  log: true,
  pretty_print_xml: true # logs formatted XML (useful while developing)
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
