---
savon_version: v2
order: 4
title: Locals
layout: guides
nav_savon_version: v2
---


Local options are passed to the client's `#call` method and are specific to a single request.

### HTTP

#### soap_action

You might need to set this if you don't have a WSDL. Otherwise, Savon should set the proper SOAPAction HTTP header for you.
If it doesn't, please open an issue and add the WSDL of your service.

``` ruby
client.call(:authenticate, soap_action: "urn:Authenticate")
```

#### cookies

Savon 2.0 tried to automatically handle cookies by storing the cookies from the last response and using them for
the next request. This is wrong and [it caused problems](https://github.com/savonrb/savon/issues/363). Savon 2.1
does not set the "Cookie" header for you, but it makes it easy for you to handle cookies yourself.

``` ruby
response     = client.call(:authenticate, message: credentials)
auth_cookies = response.http.cookies

client.call(:find_user, message: { id: 3 }, cookies: auth_cookies)
```

This option accepts an Array of `HTTPI::Cookie` objects or any object that responds to `cookies`
(like for example, an `HTTPI::Response`).


### Request

#### message

You probably want to add some arguments to your request. For simple XML which can easily be represented as a Hash,
you can pass the SOAP message as a Hash. Savon uses [Gyoku](https://github.com/savonrb/gyoku) to translate the Hash
into XML.

``` ruby
client.call(:authenticate, message: { username: 'luke', password: 'secret' })
```

For more complex XML structures, you can pass any other object that is not a Hash and responds
to `#to_s` if you want to use a more specific tool to build your request.

``` ruby
class ServiceRequest

  def to_s
    builder = Builder::XmlMarkup.new
    builder.instruct!(:xml, encoding: "UTF-8")

    builder.person { |b|
      b.username("luke")
      b.password("secret")
    }

    builder
  end

end

client.call(:authenticate, message: ServiceRequest.new)
```

#### message_tag

You can change the name of the SOAP message tag. If you need to use this option, please open an issue let me know why.

``` ruby
client.call(:authenticate, message_tag: :authenticationRequest)
```

This should be set by Savon if it has a WSDL. If it doesn't, it generates a message tag from the SOAP
operation name. Here's how the option changes the request.

``` xml
<env:Envelope
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:tns="http://v1.example.com/">
  <env:Body>
    <tns:authenticationRequest>
    </tns:authenticationRequest>
  </env:Body>
</env:Envelope>
```

#### attributes

The attributes option accepts a Hash of XML attributes for the SOAP message tag.

``` ruby
client.call(:authenticate, :attributes => { "ID" => "ABC321" })
```

Here's what the request will look like.

``` xml
<env:Envelope
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:tns="http://v1.example.com/">
  <env:Body>
    <tns:authenticationRequest ID="ABC321">
    </tns:authenticationRequest>
  </env:Body>
</env:Envelope>
```

If you need to use this option, please open an issue and provide you WSDL for debugging.
This should be handled automatically, but we need real world examples to do so.

#### soap_header

Since v2.3.0 you can specify the SOAP header per request. When both the global and local
option is used, Savon will merge the global with the local Hash.

``` ruby
client.call(:authenticate, :soap_header => { "OpToken" => "secret" })
```

#### xml

If you need to, you can even shortcut Savon's Builder and send your very own XML.

``` ruby
client.call(:authenticate, xml: "<envelope><body></body></envelope>")
```


### Response

#### advanced_typecasting

Savon by default tells [Nori](https://github.com/savonrb/nori) to use its "advanced typecasting" to convert XML values like
`"true"` to `TrueClass`, dates to date objects, etc.

``` ruby
client.call(:authenticate, advanced_typecasting: false)
```

#### response_parser

Savon defaults to [Nori's](https://github.com/savonrb/nori) Nokogiri parser. Nori ships with a REXML parser as an alternative.
If you need to switch to REXML, please open an issue and describe the problem you have with the Nokogiri parser.

``` ruby
client.call(:authenticate, response_parser: :rexml)
```
