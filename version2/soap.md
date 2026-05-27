---
savon_version: v2
order: 0
title: "SOAP and WSDL"
nav_title: "SOAP & WSDL"
description: "Learn how SOAP and WSDL work, how Savon reads a WSDL, how operation names map to Ruby symbols, and how to call services without a WSDL."
layout: guides
nav_savon_version: v2
---

SOAP (Simple Object Access Protocol) is a protocol for exchanging structured information over HTTP using XML. It is widely used in enterprise systems. When an integration partner hands you a WSDL URL instead of a REST spec, it's SOAP.

Two versions exist: [SOAP 1.1](https://www.w3.org/TR/2000/NOTE-SOAP-20000508/) and [SOAP 1.2](https://www.w3.org/TR/soap12/). Savon defaults to SOAP 1.1. Most enterprise services use 1.1. If your service requires 1.2, set `soap_version: 2` when creating the client.

Unlike REST, SOAP is contract-first: the server publishes a machine-readable description of everything it accepts, and clients are expected to follow that contract exactly. There is no browsable endpoint, no curl-and-see. You need the contract.

## WSDL

The contract is a WSDL (Web Services Description Language) document. That's an XML file usually accessible at some URL or available as a file. It describes:

- the available operations (analogous to endpoints in REST)
- the exact structure and data types of each request and response message
- the endpoint URL
- the target namespace

The [WSDL 1.1 specification](https://www.w3.org/TR/wsdl.html) defines the format. Most services you will encounter use WSDL 1.1. WSDL 2.0 exists but is rarely used in practice.

## How Savon reads the WSDL

Savon fetches and parses the WSDL lazily, the first time it needs metadata from it. For example when you call `client.operations`, make a request, or read the endpoint or namespace. Creating a client with an unreachable or broken WSDL URL will not raise on initialization. Once parsed, Savon:

- builds the list of available operations available via `client.operations`
- maps camelCase operation names to Ruby snake_case symbols
- validates that the operation you call exists, raising a `Savon::UnknownOperationError` if not
- reads the endpoint URL and namespace automatically

You do not need to parse the WSDL yourself to get started. But reading it helps when a request fails - the WSDL defines the exact element names and nesting expected, and comparing that against what Savon sends (visible with `log: true, pretty_print_xml: true`) is usually how you find the problem.

## Operation names

WSDL operation names are typically camelCase. Savon converts them to snake_case symbols: `FindUser` becomes `:find_user`, `GetAccountBalance` becomes `:get_account_balance`. Use `client.operations` to see the full list for your service.

The symbol you pass to `client.call` must match the converted name exactly.

``` ruby
client.operations
# => [:find_user, :create_user, :delete_user]

client.call(:find_user, message: { id: 42 })
```

## The message hash

The WSDL defines the expected structure of each request message. Savon converts your Ruby hash to XML. By default, symbol keys are converted to lowerCamelCase:

``` ruby
client.call(:find_user, message: { user_id: 42 })
```

``` xml
<findUser>
  <userId>42</userId>
</findUser>
```

If the service expects a different casing, use `convert_request_keys_to` in the global options. See [Globals](/version2/globals.html) for all conversion options.

## Without a WSDL

Some services do not expose a WSDL, or publish one that will not load. In that case you can create a client by providing the endpoint URL and namespace manually:

``` ruby
client = Savon.client(
  endpoint: 'https://service.example.com/users',
  namespace: 'http://v1.example.com/users'
)
```

You will also need to set `soap_action` and possibly `message_tag` per request. See [Local options](/version2/locals) for details.
