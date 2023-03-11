---
savon_version: v1
order: 6
title: Code hooks
layout: default
nav_savon_version: v1
---

Savon has a concept of hooks, which kind of work like filters which you might know from tools like
Rails or RSpec. Currently there's only one hook to use, but it's a pretty powerful one.

The hook is called `soap_request` and acts like an around filter wrapping the POST request executed
to call a SOAP service. It yields a callback object that can be called to execute the actual POST request.
It also yields the current `Savon::SOAP::Request` for you to collect information about the request.

This can be used to measure the time of the actual request:

``` ruby
Savon.configure do |config|
  config.hooks.define(:measure, :soap_request) do |callback, request|
    Timer.log(:start, Time.now)
    response = callback.call
    Timer.log(:end, Time.now)
    response
  end
end
```

or to replace the SOAP call and return a pre-defined response:

``` ruby
Savon.configure do |config|
  config.hooks.define(:mock, :soap_request) do |callback, request|
    HTTPI::Response.new(200, {}, "")
  end
end
```

This is actually how the [savon_spec](https://rubygems.org/gems/savon_spec) gem is able to mock
SOAP calls, add expectations on the request and return fixtures and pre-defined responses.

The first argument to `Savon::Hooks::Group#define` is a unique name to identify single hooks.
This can be used to remove previously defined hooks:

``` ruby
Savon.configure do |config|
  config.hooks.reject(:measure, :mock)
end
```
