---
savon_version: v1
order: 1
title: Getting started
layout: default
nav_savon_version: v1
---

Install Savon via [RubyGems.org](http://rubygems.org/gems/savon):

``` bash
gem install savon --version '~> 1.0'
```

or add it to your [Gemfile](http://gembundler.com/):

``` ruby
gem 'savon', '~> 1.0'
```

[`Savon::Client`](http://github.com/savonrb/savon/blob/master/lib/savon/client.rb) is the
interface to your SOAP service. The easiest way to get started is to use a local or remote
WSDL document.

``` ruby
client = Savon.client("http://service.example.com?wsdl")
```

`Savon.client` accepts a block inside which you can access local variables and even public
methods from your own class, but instance variables won't work. If you want to know why that is,
I'd recommend reading about
[instance_eval with delegation](http://www.dcmanges.com/blog/ruby-dsls-instance-eval-with-delegation).

If you don't like this behaviour or if it's creating a problem for you, you can accept arguments
in your block to specify which objects you would like to receive and Savon will yield those instead
of instance evaluating the block. The block accepts 1-3 arguments and yields the following objects.

    [wsdl, http, wsse]

These objects provide methods for setting up the client. In order to use the wsdl and http object,
you can specify two (of the three possible) arguments.

``` ruby
Savon.client do |wsdl, http|
  wsdl.document = "http://service.example.com?wsdl"
  http.proxy = "http://proxy.example.com"
end
```

You can also access them through methods of your client instance.

``` ruby
client.wsse.credentials "username", "password"
```

### (Not) using a WSDL

You can instantiate a client with or without a (local or remote) WSDL document. Using a WSDL
is a little easier because Savon can parse the document for the target namespace, endpoint,
available SOAP actions etc. But the (remote) WSDL has to be downloaded and parsed once for every
client which comes with a performance penalty.

To use a local WSDL, you specify the path to the file instead of the remote location:

``` ruby
Savon.client File.expand_path("../wsdl/ebay.xml", __FILE__)
```

With the client set up, you can now see what Savon knows about your service through methods offered
by [`Savon::WSDL::Document`](http://github.com/savonrb/savon/blob/master/lib/savon/wsdl/document.rb) (wsdl).
It's not too much, but it can save you some code.

``` ruby
# the target namespace
client.wsdl.namespace     # => "http://v1.example.com"

# the SOAP endpoint
client.wsdl.endpoint      # => "http://service.example.com"

# available SOAP actions
client.wsdl.soap_actions  # => [:create_user, :get_user, :get_all_users]

# the raw document
client.wsdl.to_xml        # => "<wsdl:definitions ..."
```

Your service probably uses (lower)CamelCase names for actions and params, but Savon maps those to
snake_case Symbols for you.

To use Savon without a WSDL, you initialize a client and set the SOAP endpoint and target namespace.

``` ruby
Savon.client do
  wsdl.endpoint = "http://service.example.com"
  wsdl.namespace = "http://v1.example.com"
end
```

### Qualified Locals

Savon reads the value for [elementFormDefault](http://www.w3.org/TR/xmlschema-0/#QualLocals) from a
given WSDL and defaults to `:unqualified` in case no WSDL document is used. The value specifies whether
all locally declared elements in a schema must be qualified. As of v0.9.9, the value can be manually
set to `:unqualified` or `:qualified` when setting up the client.

``` ruby
Savon.client do
  wsdl.element_form_default = :unqualified
end
```

### Preparing for HTTP

Savon uses [HTTPI](http://rubygems.org/gems/httpi) to execute GET requests for WSDL documents and
POST requests for SOAP requests. HTTPI is an interface to HTTP libraries like Curl and Net::HTTP.

The library comes with a request object called
[`HTTPI::Request`](http://github.com/savonrb/httpi/blob/master/lib/httpi/request.rb) (http)
which can accessed through the client. I'm only going to document a few details about it and
then hand over to the official documentation.

SOAPAction is an HTTP header information required by legacy services. If present, the header
value must have double quotes surrounding the URI-reference (SOAP 1.1. spec, section 6.1.1).
Here's how you would set/overwrite the SOAPAction header in case you need to:

``` ruby
client.http.headers["SOAPAction"] = '"urn:example#service"'
```

If your service relies on cookies to handle sessions, you can grab the cookie from the
[`HTTPI::Response`](http://github.com/savonrb/httpi/blob/master/lib/httpi/response.rb) and set
it for subsequent requests.

``` ruby
client.http.headers["Cookie"] = response.http.headers["Set-Cookie"]
```

### WSSE authentication

Savon comes with [`Savon::WSSE`](http://github.com/savonrb/savon/blob/master/lib/savon/wsse.rb) (wsse)
for you to use wsse:UsernameToken authentication.

``` ruby
client.wsse.credentials "username", "password"
```

Or wsse:UsernameToken digest authentication.

``` ruby
client.wsse.credentials "username", "password", :digest
```

Or wsse:Timestamp authentication.

``` ruby
client.wsse.timestamp = true
```

By setting `#timestamp` to `true`, the wsu:Created is set to `Time.now` and wsu:Expires is set to
`Time.now + 60`. You can also specify your own values manually.

``` ruby
client.wsse.created_at = Time.now
client.wsse.expires_at = Time.now + 60
```

`Savon::WSSE` is based on an
[autovivificating Hash](http://stackoverflow.com/questions/1503671/ruby-hash-autovivification-facets).
So if you need to add custom tags, you can add them.

``` ruby
client.wsse["wsse:Security"]["wsse:UsernameToken"] =
  { "Organization" => "ACME" }
```

When generating the XML for the request, this Hash will be merged with another Hash containing all the
default tags and values. This way you might digg into some code, but then you can even overwrite the
default values.
