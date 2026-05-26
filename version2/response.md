---
savon_version: v2
order: 7
title: "Read SOAP Responses"
nav_title: "Response"
description: "Read Savon SOAP responses as hashes or XML, access headers and bodies, use XPath, inspect HTTP responses, and handle error states."
layout: guides
nav_savon_version: v2
---


The response provides a few convenience methods for you to work with the XML in any way you want.

## #header

Translates the response and returns the SOAP header as a Hash.

``` ruby
response.header  # => { token: "secret" }
```

## #body

Translates the response and returns the SOAP body as a Hash.

``` ruby
response.body  # => { response: { success: true, name: "luke" } }
```

## #full_hash

Translates the response and returns the full envelope as a Hash, including both header and body.

``` ruby
response.full_hash  # => { envelope: { header: { ... }, body: { ... } } }
```

Note: `response.hash` still works but is deprecated and will be removed in a future release.

Savon uses [Nori](https://rubygems.org/gems/nori) to translate the SOAP response XML to a Hash.
You can change how the response is translated through a couple of global and local options.
The following example shows the options available to configure Nori and their defaults.

``` ruby
client = Savon.client do
  # Savon defaults to strip namespaces from the response
  strip_namespaces true

  # Savon defaults to convert Hash key Symbols to lowerCamelCase XML tags
  convert_request_keys_to :camelcase
end

client.call(:operation) do
  # Savon defaults to activate "advanced typecasting"
  advanced_typecasting true

  # Savon defaults to the Nokogiri parser
  response_parser :nokogiri
end
```

These options map to Nori's options and you can find more information about how they work in
the [README](https://github.com/savonrb/nori/blob/main/README.md).

## #to_xml

Returns the raw SOAP response.

``` ruby
response.to_xml  # => "<response><success>true</success><name>luke</name></response>"
```

## #doc

Returns the SOAP response as a [Nokogiri](https://nokogiri.org) document.

``` ruby
response.doc  # => #<Nokogiri::XML::Document:0x1017b4268 ...
```

## #xpath

Delegates to [Nokogiri's xpath method](https://nokogiri.org/rdoc/Nokogiri/XML/Node.html).

``` ruby
response.xpath("//v1:authenticateResponse/return/success").first.inner_text.should == "true"
```

## #http

Returns the underlying `Savon::Transport::Response`, which wraps the HTTP response
from the configured adapter (HTTPI or Faraday). It exposes `code`, `headers`, and
`body` for inspecting the transport-level response.

``` ruby
response.http          # => Savon::Transport::Response
response.http.code     # => 200
response.http.headers  # => { "Content-Type" => "text/xml" }
response.http.body     # => "<soap:Envelope>...</soap:Envelope>"
```

In case you disabled the global `:raise_errors` option, you can ask the response for its state.

``` ruby
response.success?     # => false
response.soap_fault?  # => true
response.http_error?  # => false
```

## #soap_fault

Returns the `Savon::SOAPFault` for the response, or `nil` when no SOAP fault occurred. Useful as a conditional when `raise_errors` is disabled:

``` ruby
if fault = response.soap_fault
  logger.warn "SOAP fault: #{fault.to_hash[:fault][:faultstring]}"
end
```

When `raise_errors` is enabled (the default), Savon raises the fault instead of returning it on the response.

## #http_error

Returns the `Savon::HTTPError` for the response, or `nil` when the HTTP layer returned a successful status. Useful as a conditional when `raise_errors` is disabled:

``` ruby
if error = response.http_error
  logger.warn "HTTP error: #{error.to_s}"
end
```

When `raise_errors` is enabled (the default), Savon raises the error instead of returning it on the response.
