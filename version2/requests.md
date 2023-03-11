---
savon_version: v2
order: 3
title: Requests
layout: guides
nav_savon_version: v2
---


To execute a SOAP request, you can ask Savon for an operation and call it with a message to send.

``` ruby
message = { username: 'luke', password: 'secret' }
response = client.call(:authenticate, message: message)
```

In this example, the Symbol `:authenticate` is the name of the SOAP operation and the `message` Hash is what
was known as the SOAP `body` Hash in version 1. The reason to change the naming is related to the SOAP request
and the fact that the former "body" never really influenced the entire SOAP body.

If Savon has a WSDL, it verifies whether your service actually contains the operation you're trying to call
and raises an `ArgumentError` in case it doesn't exist.

When you're calling a SOAP operation with a message Hash, Savon defaults to convert Hash key Symbols to
lowerCamelcase XML tags. It does not convert any Hash key Strings. You can change this with the global
`:convert_request_keys_to` option.

The operations `#call` method accepts a few local options.
