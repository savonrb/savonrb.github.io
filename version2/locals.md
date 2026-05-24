---
savon_version: v2
order: 4
title: "Local Options"
nav_title: "Locals"
description: "Per-request options for Savon SOAP calls, including SOAP action, cookies, message hashes, XML attributes, raw XML, and response parsing."
layout: guides
nav_savon_version: v2
---


Local options are passed to the client's `#call` method and are specific to a single request.

## HTTP

### soap_action

You might need to set this if you don't have a WSDL. Otherwise, Savon should set the proper SOAPAction HTTP header for you.
If it doesn't, please open an issue and add the WSDL of your service.

``` ruby
client.call(:authenticate, soap_action: "urn:Authenticate")
```

### cookies

Savon 2.0 tried to automatically handle cookies by storing the cookies from the last response and using them for
the next request. This is wrong and [it caused problems](https://github.com/savonrb/savon/issues/363). Savon 2.1
does not set the "Cookie" header for you, but it makes it easy for you to handle cookies yourself.

``` ruby
response = client.call(:authenticate, message: credentials)
auth_cookies = response.http.cookies

client.call(:find_user, message: { id: 3 }, cookies: auth_cookies)
```

This option accepts an Array of `HTTPI::Cookie` objects or any object that responds to `cookies`
(like for example, an `HTTPI::Response`).

### headers

Per-request HTTP headers. Merged with the global `headers` option, so you can keep a base set on the client and add or override just what changes for this call.

``` ruby
client.call(:find_user,
  message: { id: 42 },
  headers: { "X-Request-Id" => SecureRandom.uuid }
)
```


## Request

### message

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

### message_tag

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

### attributes

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

### soap_header

Since v2.3.0 you can specify the SOAP header per request. When both the global and local
option is used, Savon will merge the global with the local Hash and the local keys win.

``` ruby
client.call(:authenticate, :soap_header => { "OpToken" => "secret" })
```

### xml

If you need to, you can even shortcut Savon's Builder and send your very own XML.

``` ruby
client.call(:authenticate, xml: "<envelope><body></body></envelope>")
```

### attachments

Send SOAP-with-Attachments parts alongside the SOAP envelope. When `attachments`
is present, Savon sends the request as `multipart/related`. The SOAP envelope is
the root MIME part and each attachment is added as a separate part.

Savon does not add attachment references to the SOAP body automatically. Build the
SOAP message so it references the attachment Content-ID expected by your service,
usually with a `cid:` URL.

Pass an Array of hashes with `:filename` and `:content`. The filename becomes the
attachment `Content-ID` and `Content-Location`:

```ruby
client.call(:upload,
  message: {
    document: "",
    :attributes! => { document: { href: "cid:report.xml" } }
  },
  attachments: [
    { filename: "report.xml", content: "<xml>...</xml>" }
  ]
)
```

The multipart body will contain a SOAP root part and an attachment part similar to this,
with boundaries and some Mail-generated headers omitted for clarity:

```text
Content-Type: text/xml; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-ID: <soap-request-body@soap>

<env:Envelope ...>
  <env:Body>
    <tns:upload>
      <document href="cid:report.xml"></document>
    </tns:upload>
  </env:Body>
</env:Envelope>

--boundary
Content-Type: application/xml; filename=report.xml
Content-Transfer-Encoding: base64
Content-Location: report.xml
Content-ID: <report.xml>

PHhtbD4uLi48L3htbD4=
```

Pass a Hash of `"content-id" => path` to read attachments from disk. The Hash key
becomes the attachment `Content-ID`, independent of the file basename:

```ruby
client.call(:upload,
  message: {
    document: "",
    :attributes! => { document: { href: "cid:invoice" } }
  },
  attachments: {
    "invoice" => "/tmp/invoice-2026-05.pdf"
  }
)
```

Pass an Array of paths to use each file's basename as the attachment `Content-ID`:

```ruby
client.call(:upload,
  message: { user_id: 42 },
  attachments: [
    "/tmp/report.xml",
    "/tmp/scan.pdf"
  ]
)
```

Those parts can be referenced from the SOAP body as `cid:report.xml` and `cid:scan.pdf`.

This feature sends generic SOAP-with-Attachments MIME parts. Savon does not create
MTOM/XOP `xop:Include` elements, optimize base64 content, or switch the request to
MTOM `application/xop+xml` framing. If your service requires a specific element name,
namespace, or attribute for attachment references, build that XML in the `message`
or `xml` option and make sure its `cid:` value matches the attachment `Content-ID`.

## Response

### advanced_typecasting

Savon by default tells [Nori](https://github.com/savonrb/nori) to use its "advanced typecasting" to convert XML values like
`"true"` to `TrueClass`, dates to date objects, etc.

``` ruby
client.call(:authenticate, advanced_typecasting: false)
```

### response_parser

Savon defaults to [Nori's](https://github.com/savonrb/nori) Nokogiri parser. Nori ships with a REXML parser as an alternative.
If you need to switch to REXML, please open an issue and describe the problem you have with the Nokogiri parser.

``` ruby
client.call(:authenticate, response_parser: :rexml)
```

### multipart

Enable parsing of a multipart (MTOM) response for this call. Parsing is built into Savon and does not require any additional gems.

``` ruby
client.call(:download, message: { id: 42 }, multipart: true)
```

When enabled, `response.attachments` exposes the parts returned with the SOAP envelope. Set it as a [global option](/version2/globals.html) instead if every operation on the service returns multipart responses.
