---
savon_version: v2
order: 6
title: "Debug SOAP Requests"
nav_title: "Debugging"
description: "Enable Savon request and response logging, pretty-print SOAP XML, filter secrets, inspect raw responses, and diagnose common SOAP failures."
layout: guides
nav_savon_version: v2
---

When a SOAP request fails, the most useful thing you can do is see exactly what was sent and received.
Savon gives you a few tools for this.

## Enable request/response logging

Pass `log: true` and `pretty_print_xml: true` when creating the client:

``` ruby
client = Savon.client(
  wsdl: "https://example.com/service?wsdl",
  log: true,
  pretty_print_xml: true
)
```

With these options set, every request and response is printed to `$stdout`. The output looks something like this:

``` xml
<!-- Savon sending a request to http://example.com/service -->
<?xml version="1.0" encoding="UTF-8"?>
<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tns="https://example.com/">
  <env:Body>
    <tns:findUser>
      <id>42</id>
    </tns:findUser>
  </env:Body>
</env:Envelope>

<!-- Savon received the following response -->
<?xml version="1.0" encoding="UTF-8"?>
<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
  <env:Body>
    <tns:findUserResponse>
      <user>
        <id>42</id>
        <name>Luke</name>
      </user>
    </tns:findUserResponse>
  </env:Body>
</env:Envelope>
```

In a Rails app, point logging at the Rails logger so output goes to your normal log stream:

``` ruby
client = Savon.client(
  wsdl: "...",
  logger: Rails.logger,
  log_level: :debug,
  pretty_print_xml: true
)
```

## Filter sensitive values

Savon redacts any message parameters you list in `filters` before writing to the log:

``` ruby
client = Savon.client(
  wsdl: "...",
  log: true,
  pretty_print_xml: true,
  filters: [:password, :credit_card_number]
)
```

Filtered fields appear as `***FILTERED***` in both the request and response log output.

## Inspect the response directly

If you want to examine the raw response in code rather than through logs:

``` ruby
response = client.call(:find_user, message: { id: 42 })

response.to_xml      # raw XML string as received from the server
response.http.code   # HTTP status code, e.g. 200
response.http.body   # raw HTTP response body
response.body        # parsed Hash (after namespace stripping and key conversion)
```

`response.doc` returns a `Nokogiri::XML::Document` if you want to run XPath queries against the raw
response before any of Savon's transformations:

``` ruby
response.doc.xpath("//user/name").map(&:text)
```

## Common failure patterns

**Response body keys don't match what you expect**
By default, Savon strips namespaces and converts XML tags to snakecase Symbols. If the raw XML has
`<ns2:FindUserResponse>`, `response.body` will have `find_user_response:`. Use `log: true` to see the
raw XML, then trace how the keys are transformed. If the defaults don't work for your service, see
`strip_namespaces` and `convert_response_tags_to` on the [Globals](/version2/globals.html) page.

**Request XML looks wrong (wrong tag names, missing namespaces)**
Compare the logged request XML against what the service expects. If the tag casing is off, adjust
`convert_request_keys_to`. See the [Globals](/version2/globals.html) page for all options.

**Request rejected with a WSSE auth error despite correct credentials**
Add `wsse_timestamp: true`. Many services require a WS-Security timestamp alongside credentials but
don't document it. See the [Globals](/version2/globals.html) page.

**Connection errors or timeouts fetching the WSDL**
Some services put the WSDL behind the same auth as the service itself. Download the WSDL manually and
pass it as a local file path or a String:

``` ruby
Savon.client(wsdl: File.read("service.wsdl"), endpoint: "https://example.com/service")
```
