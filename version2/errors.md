---
savon_version: v2
order: 5
title: "Error Handling"
nav_title: "Errors"
description: "Handle Savon::SOAPFault, Savon::HTTPError, and Savon::InvalidResponseError, inspect fault details, and disable automatic raising when needed."
layout: guides
nav_savon_version: v2
---

## Savon::Error

The base class for all other Savon errors. This allows you to either rescue a specific error like `Savon::SOAPFault`
or rescue `Savon::Error` to catch them all.

## Savon::SOAPFault

Raised when the server returns a SOAP fault error. The error object contains the `Savon::Transport::Response` so you can further investigate
what went wrong, including its `code`, `headers`, and `body`.

``` ruby
def authenticate(credentials)
  client.call(:authenticate, message: credentials)
rescue Savon::SOAPFault => error
  Logger.log error.http.code
  raise
end
```

The example above rescues from SOAP faults, logs the HTTP response code and re-raises the SOAP fault.
You can also translate the SOAP fault response into a Hash.

``` ruby
def authenticate(credentials)
  client.call(:authenticate, message: credentials)
rescue Savon::SOAPFault => error
  fault_code = error.to_hash[:fault][:faultcode]
  fault_message = error.to_hash[:fault][:faultstring]
  raise CustomError, "#{fault_code}: #{fault_message}"
end
```

If you'd rather check for faults without raising, set `raise_errors: false` on the client and inspect the response directly:

``` ruby
client = Savon.client(wsdl: "...", raise_errors: false)
response = client.call(:authenticate, message: credentials)

if response.soap_fault?
  fault = response.body[:fault]
  puts fault[:faultcode]    # e.g. "soap:Client"
  puts fault[:faultstring]  # error message from the server
end
```

## Savon::HTTPError

Raised when Savon considers the HTTP response to be not successful. You can rescue this error and access the
transport response (`Savon::Transport::Response`) for investigation.

``` ruby
def authenticate(credentials)
  client.call(:authenticate, message: credentials)
rescue Savon::HTTPError => error
  Logger.log error.http.code
  raise
end
```

The example rescues from HTTP errors, logs the HTTP response code and re-raises the error.

## Savon::InvalidResponseError

Raised when you try to access the response header or body of a response that is not a SOAP response as a Hash.
If the response is not an XML document with an envelope, a header and a body node, it's not accessible as a Hash.

``` ruby
def get_id_from_response(response)
  response.body[:return][:id]
rescue Savon::InvalidResponseError
  Logger.log "Invalid server response"
  raise
end
```
