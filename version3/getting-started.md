---
savon_version: v3
title: Getting started
layout: default
nav: nav_versions.md
nav_savon_version: v3
---

Version 3 is [available via GitHub](https://github.com/savonrb/savon).
Add it to your [Gemfile](http://gembundler.com/) to try it out:

``` ruby
gem 'savon', github: 'savonrb/savon'
```

Instantiate Savon with a URL or the path to a local WSDL document.

``` ruby
client = Savon.new('http://example.com?wsdl')
```

Operations are separated by service and port and you need to specify them to get an Operation to call.
Savon exposes the services and ports defined by the WSDL along with their namespace and endpoint for you.

``` ruby
client.services
```

For most services, this will return a Hash with a single service and a single port, but some services
actively use multiple services and ports so you need to know about them. Here is an example for a WSDL
with a single service and port.

``` ruby
{
  'AccountService' {
    ports: {
      'AccountPort' {
        type: 'http://schemas.xmlsoap.org/wsdl/soap/',
        location: 'http://example.com/AccountService'
      }
    }
  }
}
```

With this, you can get a list of Operations for a service and port:

``` ruby
service_name = :AccountService
port_name    = :AccountPort

client.operations(service_name, port_name)
# => ['updateStatus', 'openCase', ...]
```

and more importantly, you can ask for an Operation:

``` ruby
service_name   = 'AccountService'
port_name      = 'AccountPort'
operation_name = :updateStatus

operation = client.operation(service_name, port_name, operation_name)
```

Notice how you can use both Strings and Symbols for the service, ports and operation names.
The casing matches the casing defined by the WSDL. Savon no longer converts names to snakecase
and it also doesn't treat Symbols in any special way.

Now let's look at how you can configure and call this Operation. Just like Savon exposed the
services, ports and operations, it can also tell you about the operation's parameters.

``` ruby
operation.example_body
```

This looks at the parts defined for the SOAP body and returns a Hash that follows the structure
expected by Savon (needs to be formalized) to call the operation. Keys are matching parameter-/
element-names and values indicate the simple types. Currently this Hash contains both required
and optional elements without a good way to indicate what's required and what's not. If you can
think of a nice way to accomplish this, please let me know.

``` ruby
{
  updateStatus: {
    accountID: 'string',
    accountStatus: 'string'
  }
}
```

Savon also knows the parts defined for the SOAP header and of course you can create an example
Hash for that as well. In case Savon returns an empty Hash, then there is no header and you don't
need to care about it.

``` ruby
operation.example_header
```

SOAP headers are currently limited to what's defined by the WSDL, but support for WSSE authentication
and other header-based extensions can certainly be added later.

Knowing the expected parameters for the SOAP header and body, you can add your values, set the
header and body and call the Operation.

``` ruby
operation.header = {
  Security: {
    UsernameToken: {
      Username: 'admin',
      Password: 'secret'
    }
  }
}

operation.body = {
  updateStatus: {
    accountID: 23,
    accountStatus: 'closed'
  }
}

response = operation.call
```

This returns a Response object which currently kind of works like the Response returned
by Savon 2.0, but this may still change. The main focus right now is on delivering a nice
interface for requests and working with parameters.

Apart from the header and body, the Operation also features a couple of other properties
which probably don't need to be explained in detail right now, so here they are.
Agile documentation ;)

``` ruby
# Accessor for the SOAP endpoint.
operation.endpoint

# Accessor for the SOAP version.
operation.soap_version

# Accessor for the SOAPAction HTTP header.
operation.soap_action

# Accessor for the encoding. Defaults to 'UTF-8'.
operation.encoding

# Accesor for the HTTP headers. Defaults to include the SOAPAction and Content-Length.
operation.http_headers
```

These properties affect both the request XML and the HTTP headers and until I find the
time to document them, you can generate the request XML without actually calling the
service and discover how those work.

``` ruby
operation.build
```

This returns the most beautiful SOAP you have ever seen!

``` xml
<env:Envelope
    xmlns:lol0="http://schemas.xmlsoap.org/ws/2002/07/secext"
    xmlns:lol1="http://example.com/V10"
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
  <env:Header>
    <lol0:Security>
      <UsernameToken>
        <Username>admin</Username>
        <Password>secret</Password>
      </UsernameToken>
    </lol0:Security>
  </env:Header>
  <env:Body>
    <lol1:updateStatus>
      <lol1:accountID>23</lol1:accountID>
      <lol1:accountStatus>closed</lol1:accountStatus>
    </lol1:updateStatusForManagedPublisher>
  </env:Body>
</env:Envelope>
```

More documentation coming soon. Please follow the guide, give it a try and provide feedback!

In case this crashes, please provide your WSDL for testing purposes.
The ticket for this is over at [savonrb/wasabi#27](https://github.com/savonrb/wasabi/issues/27).

Thank you!
