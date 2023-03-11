---
savon_version: v2
order: 1
title: Client
layout: guides
nav_savon_version: v2
---

Install Savon via [RubyGems.org](http://rubygems.org/gems/savon):

``` bash
gem install savon --version '~> 2.0'
```

or add it to your [Gemfile](http://gembundler.com/):

``` ruby
gem 'savon', '~> 2.0'
```

The new client is supposed be a lot simpler to use, because everything in Savon 2.0 is based on a defined set
of global and local options. To create a new client based on a WSDL document, you could set the global `:wsdl`
option by passing a Hash to the `Savon.client` "factory method". The client's constructor accepts various
[global options](#globals) which are specific to a service.

``` ruby
client = Savon.client(wsdl: "http://example.com?wsdl")
```

Along with the simple Hash-based interface, Savon also comes with an interface based on blocks. This should look
familiar to you if you used Savon 1.x before. If you're passing a block to the constructor, it is executed using the
[instance_eval with delegation](http://www.dcmanges.com/blog/ruby-dsls-instance-eval-with-delegation) pattern.
It's a smart, but ugly, but convenient little hack.

``` ruby
client = Savon.client do
  wsdl "http://example.com?wsdl"
end
```

The downside to this interface is, that it doesn't allow you to use instance variables inside the block.
You can only use local variables or call methods on your class. If you don't mind typing a few more
characters, you could accept an argument in your block and Savon will simply yield the global options
to it. That way, you can use as many instance variables as you like.

``` ruby
client = Savon.client do |globals|
  globals.wsdl @wsdl
end
```

In case your service doesn't have a WSDL, you might need to provide Savon with various other options.
For example, Savon needs to know about the SOAP endpoint and target namespace of your service.

``` ruby
client = Savon.client do
  endpoint "http://example.com"
  namespace "http://v1.example.com"
end
```

A nice little feature that comes with a WSDL, is that Savon can tell you about the available operations.

``` ruby
client.operations  # => [:authenticate, :find_user]
```

But the client really exists to send SOAP messages, so let's do that.

``` ruby
response = client.call(:authenticate, message: { username: "luke", password: "secret" })
```

If you used Savon before, this should also look familiar to you. But in contrast to the old client,
the new `#call` method does not provide the same interface as the old `#request` method. It's all about
options, so here's where you have various [local options](#locals) that are specific to a request.

The `#call` method supports the same interface as the constructor. You can pass a simple Hash or
a block to use the instance_eval with delegation pattern.

``` ruby
response = client.call(:authenticate) do
  message username: "luke", password: "secret"
  convert_request_keys_to :camelcase
end
```

You can also accept an argument in your block and Savon will yield the local options to it.

``` ruby
response = client.call(:authenticate) do |locals|
  locals.message username: "luke", password: "secret"
  locals.wsse_auth "luke", "secret", :digest
end
```
