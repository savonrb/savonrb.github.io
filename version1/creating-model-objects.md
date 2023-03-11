---
savon_version: v1
order: 4
title: Creating Model objects
layout: default
nav_savon_version: v1
---

Since v0.9.8, Savon ships with a very lightweight DSL that can be used inside or along your
domain models. You can think of it as a service mapped to a Class interface. All you need to
do is extend `Savon::Model` and your Class can act as a SOAP client.

You can either specify the location of a WSDL document:

``` ruby
class User
  extend Savon::Model

  document "http://service.example.com?wsdl"
end
```

or manually set the SOAP endpoint and target namespace and not use a WSDL:

``` ruby
class User
  extend Savon::Model

  endpoint "http://service.example.com"
  namespace "http://v1.service.example.com"
end
```

You can also set some default HTTP headers and HTTP basic and WSSE auth credentials:

``` ruby
class User
  extend Savon::Model

  headers { "AuthToken" => "BdB)33*Rdr" }

  basic_auth "username", "password"
  wsse_auth "username", "password", :digest
end
```

To really benefit from Savon's conventions and knowledge of your service, you should tell Savon about
the service methods you would like to expose through your Model. `Savon::Model` creates both class and
instance methods for every action. These methods accept a SOAP body Hash and return a
`Savon::SOAP::Response`. You can wrap them or just call them directly:

``` ruby
class User
  extend Savon::Model

  actions :get_user, :get_all_users

  def self.all
    get_all_users.to_array
  end

end
```

You can even overwrite them and delegate to `super` to call the original method:

``` ruby
class User
  extend Savon::Model

  actions :get_user, :get_all_users

  def get_user(id)
    super(user_id: id).body[:get_user_response][:return]
  end

end
```

The `Savon::Client` instance used by your Model lives at `.client` inside your class. It gets initialized
lazily whenever you call any other class or instance method that tries to access the client. In case you
need to control how the client gets initialized, you can pass a block to `.client` before it's memoized:

``` ruby
class User
  extend Savon::Model

  client do
    http.headers["Pragma"] = "no-cache"
  end

end
```

Last but not least, you can opt-out of defining any service methods and directly use the `Savon::Client` instance:

``` ruby
class User
  extend Savon::Model

  document "http://service.example.com?wsdl"

  def find_by_id(id)
    response = client.request(:find_user) do
      soap.body = { id: id }
    end

    response.body[:find_user_response][:return]
  end

end
```

In case you previously used the [savon_model](http://rubygems.org/gems/savon_model) gem, please make sure to
remove it from your project as it may conflict with the new implementation.
