---
savon_version: v2
order: 7
title: Model
layout: guides
nav_savon_version: v2
---


`Savon::Model` can be used to model a class interface on top of a SOAP service. Extending any class
with this module will give you three class methods to configure the service model.

#### .client

Sets up the client instance used by the class.

Needs to be called before any other model class method to set up the Savon client with a `:wsdl` or
the `:endpoint` and `:namespace` of the service.

``` ruby
class User
  extend Savon::Model

  client wsdl: "http://example.com?wsdl"
  # or
  client endpoint: "http://example.com", namespace: "http://v1.example.com"
end
```

#### .global

Sets a global option to a given value.

If there are multiple arguments for an option (like an auth method requiering username and password),
you can pass those as separate arguments to the `.global` method instead of passing an Array.

``` ruby
class User
  extend Savon::Model

  client wsdl: "http://example.com?wsdl"

  global :open_timeout, 30
  global :basic_auth, "luke", "secret"
end
```

#### .operations

Defines class and instance methods for the given SOAP operations.

Use this method to specify which SOAP operations should be available through your service model.

``` ruby
class User
  extend Savon::Model

  client wsdl: "http://example.com?wsdl"

  global :open_timeout, 30
  global :basic_auth, "luke", "secret"

  operations :authenticate, :find_user

  def self.find_user(id)
    super(message: { id: id })
  end
end
```

For every SOAP operation, it creates both class and instance methods. All these methods call the
service with an optional Hash of local options and return a response.

``` ruby
# instance operations
user = User.new
response = user.authenticate(message: { username: "luke", secret: "secret" })

# class operations
response = User.find_user(1)
```

In the previous User class example, we're overwriting the `.find_user` operation and delegating to `super`
with a SOAP message Hash. You can do that both on the class and on the instance.
