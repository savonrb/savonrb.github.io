---
savon_version: v2
order: 2
title: Globals
layout: default
nav: nav_versions.md
nav_savon_version: v2
---

Global options are passed to the client's constructor and are specific to a service.

Although they are called "global options", they really are local to a client instance. Savon version 1 was
based on a global `Savon.configure` method to store the configuration. While this was a popular concept
back then, adapted by tons of libraries, its problem is global state. I tried to fix that problem.

#### wsdl

Savon accepts either a local or remote WSDL document which it uses to extract information like the SOAP
endpoint and target namespace of the service. Alternatively, you can set the WSDL as a String.

``` ruby
Savon.client(wsdl: "http://example.com?wsdl")
Savon.client(wsdl: "/Users/me/project/service.wsdl")
Savon.client(wsdl: File.read("/Users/me/project/service.wsdl"))
```

For learning how to read a WSDL document, read the [Beginner's Guide](http://predic8.com/wsdl-reading.htm) by Thomas Bayer.
It's a good idea to know what you're working with and this might really help you debug certain problems.

#### endpoint and namespace

In case your service doesn't offer a WSDL, you need to tell Savon about the SOAP endpoint and target
namespace of the service.

``` ruby
Savon.client(endpoint: "http://example.com", namespace: "http://v1.example.com")
```

The target namespace is used to namespace the SOAP message. In a WSDL, the target namespace is defined on the
`wsdl:definitions` (root) node, along with the service's name and namespace declarations.

``` xml
<wsdl:definitions
  name="AuthenticationWebServiceImplService"
  targetNamespace="http://v1_0.ws.auth.order.example.com/"
  xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">
```

The SOAP endpoint is the URL at which your service accepts SOAP requests. It is usually defined at the bottom
of a WSDL, as the `location` attribute of a `soap:address` node.

``` xml
  <wsdl:service name="AuthenticationWebServiceImplService">
    <wsdl:port binding="tns:AuthenticationWebServiceImplServiceSoapBinding" name="AuthenticationWebServiceImplPort">
      <soap:address location="http://example.com/validation/1.0/AuthenticationService" />
    </wsdl:port>
  </wsdl:service>
</wsdl:definitions>
```

You can also use these options to overwrite these values in a WDSL document in case you need to.

#### raise_errors

By default, Savon raises SOAP fault and HTTP errors. You can disable both errors and query the response instead.

``` ruby
Savon.client(raise_errors: false)
```


### HTTP

#### proxy

You can specify a proxy server to use. This will be used for retrieving remote WSDL documents and actual SOAP requests.

``` ruby
Savon.client(proxy: "http://example.org")
```

#### headers

Additional HTTP headers for the request.

``` ruby
Savon.client(headers: { "Authentication" => "secret" })
```

#### timeouts

Both open and read timeout can be set (in seconds). This will be used for retrieving remote WSDL documents and actually
SOAP requests.

``` ruby
Savon.client(open_timeout: 5, read_timeout: 5)
```


### SSL

Unfortunately, SSL options were [missing from the initial 2.0 release](https://github.com/savonrb/savon/issues/344).
Please update to at least version 2.0.2 to use the following options. These will be used for retrieving remote WSDL
documents and actual SOAP requests.

#### ssl_verify_mode

You can disable SSL verification if you know what you're doing.

``` ruby
Savon.client(ssl_verify_mode: :none)
```

#### ssl_version

Change the SSL version to use.

``` ruby
Savon.client(ssl_version: :SSLv3)  # or one of [:TLSv1, :SSLv2]
```

#### ssl_cert_file

Sets the SSL cert file to use.

``` ruby
Savon.client(ssl_cert_file: "lib/client_cert.pem")
```

#### ssl_cert_key_file

Sets the SSL cert key file to use.

``` ruby
Savon.client(ssl_cert_key_file: "lib/client_key.pem")
```

#### ssl_ca_cert_file

Sets the SSL ca cert file to use.

``` ruby
Savon.client(ssl_ca_cert_file: "lib/ca_cert.pem")
```

#### ssl_cert_key_password

Sets the cert key password to decrypt an encrypted private key.

``` ruby
Savon.client(ssl_cert_key_password: "secret")
```


### Request

#### convert_request_keys_to

Savon tells [Gyoku](https://github.com/savonrb/gyoku) to convert SOAP message Hash key Symbols to lowerCamelcase tags.
You can change this to CamelCase, UPCASE or completely disable any conversion.

``` ruby
client = Savon.client do
  convert_request_keys_to :camelcase  # or one of [:lower_camelcase, :upcase, :none]
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

#### soap_header

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

#### element_form_default

Savon should extract whether to qualify elements from the WSDL. If there is no WSDL, Savon defaults to `:unqualified`.

If you specified a WSDL but still need to use this option, please open an issue and make sure to
add your WSDL for debugging. Savon currently does not support WSDL imports, so in case your service
imports its type definitions from another file, the `element_form_default` value might be wrong.

``` ruby
Savon.client(element_form_default: :qualified)
```

#### env_namespace

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

#### namespace_identifier

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

#### namespaces

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

#### encoding

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

#### soap_version

Defaults to SOAP 1.1. Can be set to SOAP 1.2 to use a different SOAP endpoint.

``` ruby
Savon.client(soap_savon_version: v2)
```


### Authentication

HTTP authentication will be used for retrieving remote WSDL documents and actual SOAP requests.

#### basic_auth

Savon supports HTTP basic authentication.

``` ruby
Savon.client(basic_auth: ["luke", "secret"])
```

#### digest_auth

And HTTP digest authentication. If you wish to use digest auth you must ensure that you have included the gem httpclient, or another one of the [HTTPI](https://github.com/savonrb/httpi) adapters that supports HTTP digest authentication.  Failing to do so will not produce errors, but if the HTTPI adapter ends up using net_http, digest authentication will not be performed.

``` ruby
Savon.client do
  digest_auth("lea", "top-secret")
end
```

#### wsse_auth

As well as WSSE basic/digest auth.

``` ruby
Savon.client(wsse_auth: ["lea", "top-secret"])

Savon.client do
  wsse_auth("lea", "top-secret", :digest)
end
```

#### wsse_timestamp

And activate WSSE timestamp auth.

``` ruby
Savon.client(wsse_timestamp: true)
```

#### ntlm

HTTPI v2.1.0 supports [NTLM authentication](http://httpirb.com/#authentication) through its `:net_http` adapter.
The optional third argument allows you to specify a domain. If the domain is omitted, it is assumed
you want to authenticate with the local server.

``` ruby
Savon.client(ntlm: ["username", "password"])
Savon.client(ntlm: ["username", "password", "domain"])
```


### Response

#### strip_namespaces

Savon configures [Nori](https://github.com/savonrb/nori) to strip any namespace identifiers from the response.
If that causes problems for you, you can disable this behavior.

``` ruby
Savon.client(strip_namespaces: false)
```

Here's how the response Hash would look like if namespaces were not stripped from the response:

``` ruby
response.hash["soap:envelope"]["soap:body"]["ns2:authenticate_response"]
```

#### convert_response_tags_to

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


### Logging

#### logger

Savon logs to `$stdout` using Ruby's default Logger. Can be changed to any compatible logger.

``` ruby
Savon.client(logger: Rails.logger)
```

#### log_level

Can be used to limit the amount of log messages by increasing the severity.
Translates the Logger's integer values to Symbols for developer happiness.

``` ruby
Savon.client(log_level: :info)  # or one of [:debug, :warn, :error, :fatal]
```

#### log

Specifies whether Savon should log requests or not. Silences HTTPI as well.

``` ruby
Savon.client(log: false)
```

#### filters

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

#### pretty_print_xml

Pretty print the request and response XML in your logs for debugging purposes.

``` ruby
Savon.client(pretty_print_xml: true)
```
