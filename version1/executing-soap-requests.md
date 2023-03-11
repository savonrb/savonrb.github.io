---
savon_version: v1
order: 2
title: Executing SOAP requests
layout: default
nav_savon_version: v1
---

Now for the fun part. To execute SOAP requests, you use the `Savon::Client#request` method. Here's a
very basic example of executing a SOAP request to a `get_all_users` action.

``` ruby
response = client.request :get_all_users
```

This single argument (the name of the SOAP action to call) works in different ways depending on whether
you're using a WSDL document. If you do, Savon will parse the WSDL document for available SOAP actions
and convert their names to snake_case Symbols for you.

Savon converts snake_case_symbols to lowerCamelCase like this:

``` ruby
:get_all_users.to_s.lower_camelcase  # => "getAllUsers"
:get_pdf.to_s.lower_camelcase        # => "getPdf"
```

This convention might not work for you if your service requires CamelCase method names or methods with
UPPERCASE acronyms. But don't worry. If you pass in a String instead of a Symbol, Savon will not convert
the argument. The difference between Symbols and String identifiers is one of Savon's convention.

``` ruby
response = client.request "GetPDF"
```

The argument(s) passed to the `#request` method will affect the SOAP input tag inside the SOAP request.  
To make sure you know what this means, here's an example for a simple request:

``` xml
<env:Envelope
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <getAllUsers />  <!-- the SOAP input tag -->
  </env:Body>
</env:Envelope>
```

Now if you need the input tag to be namespaced `<wsdl:getAllUsers />`, you pass two arguments
to the `#request` method. The first (a Symbol) will be used for the namespace and the second
(a Symbol or String) will be the SOAP action to call:

``` ruby
response = client.request :wsdl, :get_all_users
```

You may also need to bind XML attributes to the input tag. In this case, you pass a Hash of
attributes following to the name of your SOAP action and the optional namespace.

``` ruby
response = client.request :wsdl, "GetPDF", id: 1
```

These arguments result in the following input tag.

``` xml
<wsdl:GetPDF id="1" />
```

### Wrestling with SOAP

To interact with your service, you probably need to specify some SOAP-specific options.
The `#request` method is the second important method to accept a block and lets you access the
following objects.

    [soap, wsdl, http, wsse]

Notice, that the list is almost the same as the one for `Savon.client`. Except now, there is an
additional object called soap. In contrast to the other three objects, the soap object is tied to single
requests.

[`Savon::SOAP::XML`](http://github.com/savonrb/savon/blob/master/lib/savon/soap/xml.rb) (soap) can only be
accessed inside this block and Savon creates a new soap object for every request.

Savon by default expects your services to be based on SOAP 1.1. For SOAP 1.2 services, you can set the
SOAP version per request.

``` ruby
response = client.request :get_user do
  soap.version = 2
end
```

If you don't pass a namespace to the `#request` method, Savon will attach the target namespaces to
`"xmlns:wsdl"`. If you pass a namespace, Savon will use it instead of the default.

``` ruby
client.request :v1, :get_user
```

```
<env:Envelope
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:v1="http://v1.example.com">
  <env:Body>
    <v1:GetUser>
  </env:Body>
</env:Envelope>
```

You can always set namespaces and overwrite namespaces. They're stored as a Hash.

``` ruby
# setting a namespace
soap.namespaces["xmlns:g2"] = "http://g2.example.com"

# overwriting "xmlns:wsdl"
soap.namespaces["xmlns:wsdl"] = "http://ns.example.com"
```

### A little interaction

To call the `get_user` action of a service and pass the ID of the user to return, you can use
a Hash for the SOAP body.

``` ruby
response = client.request :get_user do
  soap.body = { id: 1 }
end
```

If you only need to send a single value or if you like to create a more advanced object to build
the SOAP body, you can pass any object that's not a Hash and responds to `to_s`.

``` ruby
response = client.request :get_user_by_id do
  soap.body = 1
end
```

As you already saw before, Savon is based on a few conventions to make the experience of having to
work with SOAP and XML as pleasant as possible. The Hash is translated to XML using
[Gyoku](http://rubygems.org/gems/gyoku) which is based on the same conventions.

``` ruby
soap.body = {
  :first_name => "The",
  :last_name  => "Hoff",
  "FAME"      => ["Knight Rider", "Baywatch"]
}
```

As with the SOAP action, Symbol keys will be converted to lowerCamelCase and String keys won't be
touched. The previous example generates the following XML.

``` xml
<env:Envelope
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:wsdl="http://v1.example.com">
  <env:Body>
    <wsdl:CreateUser>
      <firstName>The</firstName>
      <lastName>Hoff</lastName>
      <FAME>Knight Rider</FAME>
      <FAME>Baywatch</FAME>
    </wsdl:CreateUser>
  </env:Body>
</env:Envelope>
```

Some services actually require the XML elements to be in a specific order. If you don't use Ruby 1.9
(and you should), you can not be sure about the order of Hash elements and have to specify the correct
order using an Array under a special `:order!` key.

``` ruby
{
  :last_name  => "Hoff",
  :first_name => "The",
  :order!     => [:first_name, :last_name]
}
```

This will make sure, that the lastName tag follows the firstName.

Assigning arguments to XML tags using a Hash is even more difficult. It requires another Hash under
an `:attributes!` key containing a key matching the XML tag and the Hash of attributes to add.

``` ruby
{
  :city        => nil,
  :attributes! => { :city => { "xsi:nil" => true } }
}
```

This example will be translated to the following XML.

``` xml
<city xsi:nil="true"></city>
```

I would not recommend using a Hash for the SOAP body if you need to create complex XML structures,
because there are better alternatives. One of them is to pass a block to the `Savon::SOAP::XML#body`
method. Savon will then yield a `Builder::XmlMarkup` instance for you to use.

``` ruby
soap.body do |xml|
  xml.firstName("The")
  xml.lastName("Hoff")
end
```

Last but not least, you can also create and use a simple String (created with Builder or any another tool):

``` ruby
soap.body = "<firstName>The</firstName><lastName>Hoff</lastName>"
```

Besides the body element, SOAP requests can also contain a header with additional information.
Savon sees this header as just another Hash following the same conventions as the SOAP body Hash.

``` ruby
soap.header = { "SecretKey" => "secret" }
```

If you're sure that none of these options work for you, you can completely customize the XML to be used
for the SOAP request.

``` ruby
soap.xml = "<custom><soap>request</soap></custom>"
```

The `Savon::SOAP::XML#xml` method also accepts a block and yields a `Builder::XmlMarkup` instance.

``` ruby
namespaces = {
  "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
  "xmlns:blz" => "http://thomas-bayer.com/blz/"
}

soap.xml do |xml|
  xml.soapenv(:Envelope, namespaces) do |xml|
    xml.soapenv(:Body) do |xml|
      xml.blz(:getBank) do |xml|
        xml.blz(:blz, "24050110")
      end
    end
  end
end
```

Please take a look at the examples for some hands-on exercise.
