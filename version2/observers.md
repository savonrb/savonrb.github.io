---
savon_version: v2
order: 9
title: Observers
layout: guides
nav_savon_version: v2
---


Savon has one global way of adding observers to any request.

``` ruby
class Observer

  def notify(operation_name, builder, globals, locals)
    nil
  end

end

Savon.observers << Observer.new
```

Savon calls the `#notify` method of every observer in the order they were added and passes the name of
the operation that is being called, the builder which can be asked for the generated request XML and
any global and local options.

In the previous example, we're explicitly returning `nil` from the `#notify` method to allow Savon to
continue and execute the request. But you can also return an `HTTPI::Response` to mock the request.

``` ruby
class Observer

  def notify(operation_name, builder, globals, locals)
    code    = 200
    headers = {}
    body    = ""

    HTTPI::Response.new(code, headers, body)
  end

end

Savon.observers << Observer.new
```

Clear the observers if you don't need them.

``` ruby
Savon.observers.clear
```
