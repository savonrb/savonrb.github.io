---
savon_version: v2
order: 2
title: "Global Options"
nav_title: "Globals"
description: "Reference for Savon client options covering WSDL, endpoint, headers, timeouts, SSL, authentication, logging, request XML, and response parsing."
layout: guides
nav_savon_version: v2
---

Global options are passed to the client's constructor and are specific to a service.
Although they are called "global options", they really are local to a client instance.

Options marked with a <span class="option-badge option-badge-deprecated">deprecated under Faraday</span>
badge belong to the HTTPI transport layer. They keep working with the default `transport: :httpi`, but
Savon rejects them when you opt into `transport: :faraday`. Faraday exposes its own setup API for
proxies, timeouts, TLS, auth, redirects, and adapters. Configure those through `client.faraday` instead.
See the [`transport`](#transport) option below for examples. If you mix them, Savon raises a
`Savon::InitializationError` that points you at the matching Faraday call.

## Service setup

### wsdl

Savon accepts either a local or remote WSDL document which it uses to extract information like the SOAP
endpoint and target namespace of the service. Alternatively, you can set the WSDL as a String.

``` ruby
Savon.client(wsdl: "https://example.com?wsdl")
Savon.client(wsdl: "/Users/me/project/service.wsdl")
Savon.client(wsdl: File.read("/Users/me/project/service.wsdl"))
```

For learning how to read a WSDL document, read the [Beginner's Guide](http://predic8.com/wsdl-reading.htm) by Thomas Bayer.
It's a good idea to know what you're working with and this might really help you debug certain problems.

### endpoint

The URL at which your service accepts SOAP requests. Required when your service doesn't offer a WSDL. Can also be used to overwrite the endpoint defined in a WSDL document.

``` ruby
Savon.client(endpoint: "https://example.com", namespace: "http://v1.example.com")
```

In a WSDL, the SOAP endpoint is usually defined at the bottom as the `location` attribute of a `soap:address` node.

``` xml
  <wsdl:service name="AuthenticationWebServiceImplService">
    <wsdl:port binding="tns:AuthenticationWebServiceImplServiceSoapBinding" name="AuthenticationWebServiceImplPort">
      <soap:address location="https://example.com/validation/1.0/AuthenticationService" />
    </wsdl:port>
  </wsdl:service>
</wsdl:definitions>
```

### namespace

The target namespace of the service, used to namespace the SOAP message. Required when your service doesn't offer a WSDL. Can also be used to overwrite the namespace defined in a WSDL document.

``` ruby
Savon.client(endpoint: "https://example.com", namespace: "http://v1.example.com")
```

In a WSDL, the target namespace is defined on the `wsdl:definitions` (root) node, along with the service's name and namespace declarations.

``` xml
<wsdl:definitions
  name="AuthenticationWebServiceImplService"
  targetNamespace="http://v1_0.ws.auth.order.example.com/"
  xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">
```

### raise_errors

By default, Savon raises SOAP fault and HTTP errors. You can disable both errors and query the response instead.

``` ruby
Savon.client(raise_errors: false)
```


## HTTP

### proxy

<p class="option-badge-row"><a class="option-badge option-badge-deprecated" href="#transport">deprecated under Faraday</a></p>

You can specify a proxy server to use. This will be used for retrieving remote WSDL documents and actual SOAP requests.

``` ruby
Savon.client(proxy: "https://example.org")
```

### headers

Additional HTTP headers for the request.

``` ruby
Savon.client(headers: { "Authentication" => "secret" })
```

### open_timeout

<p class="option-badge-row"><a class="option-badge option-badge-deprecated" href="#transport">deprecated under Faraday</a></p>

How long Savon waits (in seconds) to establish a connection. Used for both retrieving remote WSDL documents and sending SOAP requests.

``` ruby
Savon.client(open_timeout: 5)
```

### read_timeout

<p class="option-badge-row"><a class="option-badge option-badge-deprecated" href="#transport">deprecated under Faraday</a></p>

How long Savon waits (in seconds) for the server to send response data after the request has been sent. Used for both retrieving remote WSDL documents and sending SOAP requests.

``` ruby
Savon.client(read_timeout: 5)
```

### write_timeout

<p class="option-badge-row"><a class="option-badge option-badge-deprecated" href="#transport">deprecated under Faraday</a></p>

How long Savon waits (in seconds) when sending the request body. Useful when uploading large payloads or attachments.

``` ruby
Savon.client(write_timeout: 30)
```

### adapter

<p class="option-badge-row"><a class="option-badge option-badge-deprecated" href="#transport">deprecated under Faraday</a></p>

Selects the [HTTPI](https://github.com/savonrb/httpi) adapter used by the client.

``` ruby
Savon.client(wsdl: "https://example.com?wsdl", adapter: :httpclient)
```

This option is HTTPI-specific. With `transport: :faraday`, configure the adapter through `client.faraday` instead.

### transport

Defaults to `:httpi` using [HTTPI](https://rubygems.org/gems/httpi). Set to `:faraday` to use a [Faraday](https://github.com/lostisland/faraday) connection instead.

``` ruby
Savon.client(wsdl: "...", transport: :faraday)
```

When using the Faraday transport, access `client.faraday` to configure the connection before making
any calls. It returns a `Faraday::Connection` that you configure directly:

``` ruby
client = Savon.client(wsdl: "...", transport: :faraday)

conn = client.faraday
conn.headers["Authorization"] = "Bearer token"
conn.options.timeout = 10
conn.ssl.verify = false
```

The Faraday transport unlocks features that HTTPI does not support: redirect following for WSDL fetches
(via `faraday-follow-redirects`) and digest authentication (via `faraday-digestauth`).

Note: httpi-specific options like `proxy`, `open_timeout`, `read_timeout`, SSL options, and `adapter`
cannot be used alongside `transport: :faraday`. Savon will raise a helpful error if you mix them.
Configure those through `client.faraday` instead.


## SSL

These will be used for retrieving remote WSDL documents and actual SOAP requests.

### ssl_verify_mode

<p class="option-badge-row"><a class="option-badge option-badge-deprecated" href="#transport">deprecated under Faraday</a></p>

You can disable SSL verification if you know what you're doing.

``` ruby
Savon.client(ssl_verify_mode: :none)
```

### ssl_version

<p class="option-badge-row"><a class="option-badge option-badge-deprecated" href="#transport">deprecated under Faraday</a></p>

Change the SSL version to use.

``` ruby
Savon.client(ssl_version: :SSLv3)  # or one of [:TLSv1, :SSLv2]
```

### ssl_min_version

<p class="option-badge-row"><a class="option-badge option-badge-deprecated" href="#transport">deprecated under Faraday</a></p>

Sets the lowest TLS version allowed during the handshake. Useful when you want to refuse anything below a known-safe floor while still allowing the server and client to negotiate a newer version.

``` ruby
Savon.client(ssl_min_version: :TLS1_2)
```

### ssl_max_version

<p class="option-badge-row"><a class="option-badge option-badge-deprecated" href="#transport">deprecated under Faraday</a></p>

Sets the highest TLS version allowed during the handshake. Pair with `ssl_min_version` to constrain negotiation to a version range instead of pinning a single version with `ssl_version`.

``` ruby
Savon.client(ssl_max_version: :TLS1_3)
```

### ssl_ciphers

<p class="option-badge-row"><a class="option-badge option-badge-deprecated" href="#transport">deprecated under Faraday</a></p>

Restrict the cipher suites offered during the TLS handshake. The value is passed straight through to OpenSSL, so any cipher string accepted by your OpenSSL build works.

``` ruby
# Only high-strength suites, no anonymous auth, no MD5
Savon.client(ssl_ciphers: "HIGH:!aNULL:!MD5")
```

### ssl_cert_file

<p class="option-badge-row"><a class="option-badge option-badge-deprecated" href="#transport">deprecated under Faraday</a></p>

Sets the SSL cert file to use, or sets the path to the directory that contains the cert file(s).

``` ruby
Savon.client(ssl_cert_file: "lib/client_cert.pem")
```

### ssl_cert_key_file

<p class="option-badge-row"><a class="option-badge option-badge-deprecated" href="#transport">deprecated under Faraday</a></p>

Sets the SSL cert key file to use.

``` ruby
Savon.client(ssl_cert_key_file: "lib/client_key.pem")
```

### ssl_ca_cert_file

<p class="option-badge-row"><a class="option-badge option-badge-deprecated" href="#transport">deprecated under Faraday</a></p>

Sets the SSL ca cert file to use, or sets the path to the directory that contains the ca cert file(s).

``` ruby
Savon.client(ssl_ca_cert_file: "lib/ca_cert.pem")
```

### ssl_ca_cert_path

<p class="option-badge-row"><a class="option-badge option-badge-deprecated" href="#transport">deprecated under Faraday</a></p>

Path to a directory of trusted CA certificates. Use this when you have a directory of certs instead of a single bundle file.

``` ruby
Savon.client(ssl_ca_cert_path: "/etc/ssl/certs")
```

### ssl_cert_store

<p class="option-badge-row"><a class="option-badge option-badge-deprecated" href="#transport">deprecated under Faraday</a></p>

An `OpenSSL::X509::Store` to use for certificate verification. Useful when you build a custom trust store at boot and want every Savon client to share it.

``` ruby
store = OpenSSL::X509::Store.new
store.set_default_paths
store.add_file("config/internal_ca.pem")

Savon.client(ssl_cert_store: store)
```

### ssl_cert_key_password

<p class="option-badge-row"><a class="option-badge option-badge-deprecated" href="#transport">deprecated under Faraday</a></p>

Sets the cert key password to decrypt an encrypted private key.

``` ruby
Savon.client(ssl_cert_key_password: "secret")
```


## Request

### convert_request_keys_to

Savon tells [Gyoku](https://github.com/savonrb/gyoku) to convert SOAP message Hash key Symbols to lowerCamelcase tags.
You can change this to CamelCase, UPCASE or completely disable any conversion.

| Value | `:user_name` becomes |
|---|---|
| `:lower_camelcase` (default) | `<userName>` |
| `:camelcase` | `<UserName>` |
| `:upcase` | `<USER_NAME>` |
| `:none` | `<user_name>` |

``` ruby
client = Savon.client do
  convert_request_keys_to :camelcase
end

client.call(:find_user) do
  message(user_name: "luke")
end
```

This example converts all keys in the request Hash to CamelCase tags.

``` xml
<env:Envelope
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:wsdl="http://v1.example.com">
  <env:Body>
    <wsdl:FindUser>
      <UserName>luke</UserName>
    </wsdl:FindUser>
  </env:Body>
</env:Envelope>
```

### soap_header

If you need to add custom XML to the SOAP header, you can use this option. This might be useful for setting a global
authentication token or any other kind of metadata.

``` ruby
Savon.client(soap_header: { "Token" => "secret" })
```

This is the header created for the options:

``` xml
<env:Envelope
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:v1="http://v1.example.com/">
  <env:Header>
    <Token>secret</Token>
  </env:Header>
</env:Envelope>
```

### element_form_default

Savon should extract whether to qualify elements from the WSDL. If there is no WSDL, Savon defaults to `:unqualified`.

If you specified a WSDL but still need to use this option, please open an issue and make sure to
add your WSDL for debugging. Savon currently does not support WSDL imports, so in case your service
imports its type definitions from another file, the `element_form_default` value might be wrong.

``` ruby
Savon.client(element_form_default: :qualified)
```

### env_namespace

Savon defaults to use `:env` as the namespace identifier for the SOAP envelope. If that doesn't work  for you, I would
like to know why. So please open an issue and make sure to add your WSDL for debugging.

``` ruby
Savon.client(env_namespace: :soapenv)
```

This is how the request's `envelope` looks like after changing the namespace identifier:

``` xml
<soapenv:Envelope
  xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
```

### namespace_identifier

Should be extracted from the WSDL. If it doesn't have a WSDL, Savon falls back to `:wsdl`. No idea why anyone
would need to use this option.

``` ruby
Savon.client(namespace_identifier: :v1)
```

Notice the `v1:authenticate` message tag in the generated request:

``` xml
<env:Envelope
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:v1="http://v1.example.com/">
  <env:Body>
    <v1:authenticate></v1:authenticate>
  </env:Body>
</env:Envelope>
```

### namespaces

You can add additional namespaces to the SOAP envelope tag.

``` ruby
namespaces = {
  "xmlns:v2" => "http://v2.example.com",
}

Savon.client(namespaces: namespaces)
```

This does what you would expect it to do. If you need to use this option, please open an issue and provide
your WSDL for debugging.

``` xml
<env:Envelope
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:v1="http://v1.example.com/"
    xmlns:v2="http://v2.example.com/">
  <env:Body>
    <v1:authenticate></v1:authenticate>
  </env:Body>
</env:Envelope>
```

### encoding

Savon defaults to UTF-8.

``` ruby
Savon.client(encoding: "UTF-16")
```

Changing the default affects both the Content-Type header:

``` ruby
{ "Content-Type" => "text/xml;charset=UTF-16" }
```

and the XML instruction:

``` xml
<?xml version="1.0" encoding="UTF-16"?>
```

### soap_version

Defaults to SOAP 1.1. Set to `2` to use SOAP 1.2, which changes the envelope namespace and the request `Content-Type` accordingly.

``` ruby
Savon.client(soap_version: 2)
```

### unwrap

Tells [Gyoku](https://github.com/savonrb/gyoku) to unwrap an Array of Hashes when building the request. Without it, Gyoku wraps each Hash in a parent tag matching the key. With `unwrap: true`, the parent tag is repeated for each entry instead.

``` ruby
Savon.client(unwrap: true)

client.call(:create_users, message: {
  users: [{ name: "luke" }, { name: "lea" }]
})
```

``` xml
<users>
  <name>luke</name>
</users>
<users>
  <name>lea</name>
</users>
```

Defaults to `false`.


## Authentication

HTTP authentication will be used for retrieving remote WSDL documents and actual SOAP requests.

### basic_auth

<p class="option-badge-row"><a class="option-badge option-badge-deprecated" href="#transport">deprecated under Faraday</a></p>

Savon supports HTTP basic authentication.

``` ruby
Savon.client(basic_auth: ["luke", "secret"])
```

### digest_auth

<p class="option-badge-row"><a class="option-badge option-badge-deprecated" href="#transport">deprecated under Faraday</a></p>

And HTTP digest authentication. If you wish to use digest auth you must ensure that you have included the gem httpclient, or another one of the [HTTPI](https://github.com/savonrb/httpi) adapters that supports HTTP digest authentication.  Failing to do so will not produce errors, but if the HTTPI adapter ends up using net_http, digest authentication will not be performed.

``` ruby
Savon.client do
  digest_auth("lea", "top-secret")
end
```

### wsse_auth

As well as WSSE basic/digest auth.

``` ruby
Savon.client(wsse_auth: ["lea", "top-secret"])

Savon.client do
  wsse_auth("lea", "top-secret", :digest)
end
```

### wsse_timestamp

Adds a WS-Security timestamp to every request. Many enterprise services require this even when their documentation doesn't mention it. If you're getting authentication failures or `wsse:InvalidSecurity` faults despite correct credentials, adding this option is often the fix.

``` ruby
Savon.client(wsse_timestamp: true)
```

Combine with `wsse_auth` when the service requires both credentials and a timestamp:

``` ruby
Savon.client(
  wsse_auth: ["username", "password", :digest],
  wsse_timestamp: true
)
```

### wsse_signature

XML Signature support via [Akami](https://github.com/savonrb/akami). Sign the SOAP envelope with an X.509 certificate when the service requires it.

``` ruby
wsse_signature = Akami::WSSE::Signature.new(
  Akami::WSSE::Certs.new(
    cert_file: "client_cert.pem",
    private_key_file: "client_key.pem"
  )
)

Savon.client(wsdl: "https://example.com?wsdl", wsse_signature:)
```

This is independent of `wsse_auth`. A service may require either, both, or neither.

### ntlm

<p class="option-badge-row"><a class="option-badge option-badge-deprecated" href="#transport">deprecated under Faraday</a></p>

HTTPI v2.1.0 supports [NTLM authentication](http://httpirb.com/#authentication) through its `:net_http` adapter.
The optional third argument allows you to specify a domain. If the domain is omitted, it is assumed
you want to authenticate with the local server.

``` ruby
Savon.client(ntlm: ["username", "password"])
Savon.client(ntlm: ["username", "password", "domain"])
```


## Response

### strip_namespaces

Savon configures [Nori](https://github.com/savonrb/nori) to strip any namespace identifiers from the response.
If that causes problems for you, you can disable this behavior.

``` ruby
Savon.client(strip_namespaces: false)
```

Here's how the response Hash would look like if namespaces were not stripped from the response:

``` ruby
response.hash["soap:envelope"]["soap:body"]["ns2:authenticate_response"]
```

### convert_response_tags_to

Savon tells [Nori](https://github.com/savonrb/nori) to convert any XML tag from the response to a snakecase Symbol.
This is why accessing the response as a Hash looks natural:

``` ruby
response.body[:user_response][:id]
```

You can specify your own `Proc` or any object that responds to `#call`. It is called for every XML
tag and simply has to return the converted tag.

``` ruby
upcase = lambda { |key| key.snakecase.upcase }
Savon.client(convert_response_tags_to: upcase)
```

You can have it your very own way.

``` ruby
response.body["USER_RESPONSE"]["ID"]
```

### delete_namespace_attributes

Tells [Nori](https://github.com/savonrb/nori) to drop `xmlns:*` attributes from the response. Defaults to `false`. Enable it when those attributes survive `strip_namespaces` and clutter the Hash you actually want to work with.

``` ruby
Savon.client(delete_namespace_attributes: true)
```

### multipart

<p class="option-badge-row"><span class="option-badge option-badge-deprecated">deprecated</span></p>

No-op since v2.13.0. Savon detects multipart (MTOM) responses from the `Content-Type`
header and parses them regardless of this option, so it never enabled or disabled
anything. Safe to remove. When the response is multipart, `response.attachments`
exposes the parts attached to the response.


## Logging

### logger

Savon logs to `$stdout` using Ruby's default Logger. Can be changed to any compatible logger.

``` ruby
Savon.client(logger: Rails.logger)
```

### log_level

Can be used to limit the amount of log messages by increasing the severity.
Translates the Logger's integer values to Symbols for developer happiness.

``` ruby
Savon.client(log_level: :info)  # or one of [:debug, :warn, :error, :fatal]
```

### log

Specifies whether Savon should log requests or not. Silences HTTPI as well.

``` ruby
Savon.client(log: false)
```

### filters

Sensitive information should probably be removed from logs. If you don't have a central way of filtering your logs,
you can tell Savon about the message parameters to filter for you.

``` ruby
Savon.client(filters: [:password])
```

This filters the password in both the request and response.

``` xml
<env:Envelope
    xmlns:env='http://schemas.xmlsoap.org/soap/envelope/'
    xmlns:tns='http://v1_0.ws.auth.order.example.com/'>
  <env:Body>
    <tns:authenticate>
      <username>luke</username>
      <password>***FILTERED***</password>
    </tns:authenticate>
  </env:Body>
</env:Envelope>
```

### pretty_print_xml

Pretty print the request and response XML in your logs for debugging purposes.

``` ruby
Savon.client(pretty_print_xml: true)
```

### log_headers

Whether HTTP request and response headers are logged alongside the bodies. Defaults to `true`. Turn it off when headers carry tokens or cookies you do not want in your log output and you cannot rely on `filters` (which only redacts XML elements in the body).

``` ruby
Savon.client(log: true, log_headers: false)
```
