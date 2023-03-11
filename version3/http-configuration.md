---
savon_version: v3
title: HTTP configuration
layout: default
nav_savon_version: v3
---

Savon uses a simple adapter based on the [HTTPClient](https://github.com/nahi/httpclient) gem.
You can get access to the HTTPClient instance to configure authentication and other details.

``` ruby
client.http
```

As Savon resolves imports on instantiation, this might not work for you. So if you need to
configure the HTTP client for those imports or if you have any other especially complicated
HTTP configurations, you can use your own adapter which only has to support three methods as
illustrated by this [specification](https://github.com/savonrb/savon/blob/version3/spec/savon/httpclient_spec.rb).
You can then globally change the adapter to use.

``` ruby
Savon.http_adapter = MyAdapter
```

or you can pass an instance of your adapter to Savon to only use it per-client.

``` ruby
Savon.new(wsdl_url, MyAdapter.new)
```
