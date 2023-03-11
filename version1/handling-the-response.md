---
savon_version: v1
order: 3
title: Handling the response
layout: default
nav_savon_version: v1
---

`Savon::Client#request` returns a
[`Savon::SOAP::Response`](http://github.com/savonrb/savon/blob/master/lib/savon/soap/response.rb).
Everything's really just a Hash.

``` ruby
response.to_hash  # => { :response => { :success => true, :name => "John" } }
```

Alright, sometimes it's XML.

``` ruby
response.to_xml  # => "<response><success>true</success><name>John</name></response>"
```

The response also contains the [`HTTPI::Response`](http://github.com/savonrb/httpi/blob/master/lib/httpi/response.rb)
which (obviously) contains information about the HTTP response.

``` ruby
response.http  # => #<HTTPI::Response:0x1017b4268 ...
```

### In case of an emergency

By default, Savon raises both `Savon::SOAP::Fault` and `Savon::HTTP::Error` when encountering these
kind of errors.

``` ruby
begin
  client.request :get_all_users
rescue Savon::SOAP::Fault => fault
  log fault.to_s
end
```

Both errors inherit from `Savon::Error`, so you can catch both very easily.

``` ruby
begin
  client.request :get_all_users
rescue Savon::Error => error
  log error.to_s
end
```

You can change the default of raising errors and if you did, you can still ask the response to check
whether the request was successful.

``` ruby
response.success?     # => false
response.soap_fault?  # => true
response.http_error?  # => false
```

And you can access the error objects themselves.

``` ruby
response.soap_fault  # => Savon::SOAP::Fault
response.http_error  # => Savon::HTTP::Error
```

Please notice, that these methods always return an error object, even if no error exists. To check if
an error occured, you can either ask the response or the error objects.

``` ruby
response.soap_fault.present?  # => true
response.http_error.present?  # => false
```
