---
savon_version: v2
order: 3
title: "Calling SOAP Operations"
nav_title: "Requests"
description: "How Savon assembles a SOAP request: the envelope, header, body, and message and which Savon options control each part."
layout: guides
nav_savon_version: v2
---

Calling `client.call` builds a SOAP envelope from the options you provide, sends it over HTTP, and returns a [Response](/version2/response.html). This page covers what Savon actually assembles and which options control each part of the envelope.

For background on SOAP and WSDL themselves, see [SOAP & WSDL](/version2/soap.html).

## Making a call

Pass the operation name as a Symbol along with any [local options](/version2/locals.html):

``` ruby
response = client.call(:authenticate, message: { username: "luke", password: "secret" })
```

The Symbol must match an operation the service exposes. With a WSDL, Savon validates the name and raises a `Savon::UnknownOperationError` when it doesn't exist. Use `client.operations` to see the full list.

The block form is equivalent and useful when you want to set several options without building a Hash:

``` ruby
response = client.call(:authenticate) do
  message username: "luke", password: "secret"
  soap_header "Token" => "secret"
end
```

## Anatomy of a SOAP request

Given a client with a WSDL and the call above, Savon sends something like this:

``` xml
<env:Envelope
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:tns="http://v1.example.com/">
  <env:Header>
    <Token>secret</Token>
  </env:Header>
  <env:Body>
    <tns:authenticate>
      <username>luke</username>
      <password>secret</password>
    </tns:authenticate>
  </env:Body>
</env:Envelope>
```

Every part comes from an option you or the WSDL provided.

### Envelope

The outer wrapper. Savon picks the envelope prefix from the [`env_namespace`](/version2/globals.html#env_namespace) global (default `env`) and the target namespace from [`namespace`](/version2/globals.html#namespace), which is read from the WSDL when available. Add more namespaces with the [`namespaces`](/version2/globals.html#namespaces) global.

The SOAP version is controlled by [`soap_version`](/version2/globals.html#soap_version) (default `1`). Savon uses the matching envelope namespace automatically.

### Header

Optional, for metadata that isn't part of the operation payload like auth tokens, correlation IDs, WS-Security blocks.

- Set a static header on the client with the [`soap_header`](/version2/globals.html#soap_header) global.
- Override or extend it per call with the [`soap_header`](/version2/locals.html#soap_header) local.
- For WS-Security, use [`wsse_auth`](/version2/globals.html#wsse_auth), [`wsse_timestamp`](/version2/globals.html#wsse_timestamp), or [`wsse_signature`](/version2/globals.html#wsse_signature) and Savon adds the right elements to the header for you.

### Body

The Body wraps the payload in a single element named after the operation. Savon takes the name from the WSDL when available, otherwise from the operation symbol.Override it with the [`message_tag`](/version2/locals.html#message_tag) local when you need to, and add XML attributes to the tag with the [`attributes`](/version2/locals.html#attributes) local.

### Message

The contents of the body tag come from the [`message`](/version2/locals.html#message) local. Pass a Hash and Savon converts it to XML using [Gyoku](https://github.com/savonrb/gyoku). Symbol keys become lowerCamelCase tags by default. Change that with the [`convert_request_keys_to`](/version2/globals.html#convert_request_keys_to) global. String keys are passed through untouched which is useful when you need a tag name the Symbol conversion can't produce.

For XML that doesn't map cleanly to a Hash, pass any object that responds to `#to_s`, or skip Savon's builder entirely with the [`xml`](/version2/locals.html#xml) local. See [Locals](/version2/locals.html) for examples.

## Beyond the envelope

A request also carries HTTP-level state and, optionally, MIME parts:

- **HTTP headers and SOAPAction**: set base headers on the client with the [`headers`](/version2/globals.html#headers) global, then add or override per call with the [`headers`](/version2/locals.html#headers) local. Set the SOAPAction explicitly with [`soap_action`](/version2/locals.html#soap_action), or pass [`cookies`](/version2/locals.html#cookies) from a previous response.
- **Attachments**: pass an Array or Hash to the [`attachments`](/version2/locals.html#attachments) local to send a `multipart/related` request with the envelope as the root part.

## Inspecting what Savon sent

Turn on request logging to see the exact XML Savon sends over the wire:

``` ruby
client = Savon.client(
  wsdl: "https://example.com?wsdl",
  pretty_print_xml: true,
  log: true
)
```

See [Debugging](/version2/debugging.html) for more options.
