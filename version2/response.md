---
savon_version: v2
order: 6
title: Response
layout: guides
nav_savon_version: v2
---


The response provides a few convenience methods for you to work with the XML in any way you want.

#### #header

Translates the response and returns the SOAP header as a Hash.

``` ruby
response.header  # => { token: "secret" }
```

#### #body

Translates the response and returns the SOAP body as a Hash.

``` ruby
response.body  # => { response: { success: true, name: "luke" } }
```

#### #hash

Translates the response and returns it as a Hash.

``` ruby
response.hash  # => { envelope: { header: { ... }, body: { ... } } }
```

Savon uses [Nori](http://rubygems.org/gems/nori) to translate the SOAP response XML to a Hash.
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

#### #to_xml

Returns the raw SOAP response.

``` ruby
response.to_xml  # => "<response><success>true</success><name>luke</name></response>"
```

#### #doc

Returns the SOAP response as a [Nokogiri](http://nokogiri.org/) document.

``` ruby
response.doc  # => #<Nokogiri::XML::Document:0x1017b4268 ...
```

#### #xpath

Delegates to [Nokogiri's xpath method](http://nokogiri.org/Nokogiri/XML/Node.html#method-i-xpath).

``` ruby
response.xpath("//v1:authenticateResponse/return/success").first.inner_text.should == "true"
```

#### #http

Returns the [HTTPI](https://github.com/savonrb/httpi) response.

``` ruby
response.http  # => #<HTTPI::Response:0x1017b4268 ...
```

In case you disabled the global `:raise_errors` option, you can ask the response for its state.

``` ruby
response.success?     # => false
response.soap_fault?  # => true
response.http_error?  # => false
```
