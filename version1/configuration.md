---
savon_version: v1
order: 5
title: Configuration
layout: default
nav_savon_version: v1
---

Savon provides a couple of basic configuration options:

``` ruby
Savon.configure do |config|

  # By default, Savon logs each SOAP request and response to $stdout.
  # Here's how you can disable logging:
  config.log = false

  # The default log level used by Savon is :debug.
  config.log_level = :info

  # In a Rails application you might want Savon to use the Rails logger.
  config.logger = Rails.logger

  # The XML logged by Savon can be formatted for debugging purposes.
  # Unfortunately, this feature comes with a performance and is not
  # recommended for production environments.
  config.pretty_print_xml = true

  # Savon raises SOAP and HTTP errors, but you can disabling this behavior.
  config.raise_errors = false

  # Savon expects your service to use SOAP 1.1. You can change that to 1.2
  # which affects error handling and smaller differences. If you have to
  # set this, it's probably a bug. Please open a ticket.
  config.soap_version = 2

  # The XML namespace identifier used for the SOAP envelope defaults to :env
  # but can be configured to use a different identifier. If you need this
  # feature, please open a ticket because Savon should figure out the
  # namespace and identifier itself.
  config.env_namespace = :soapenv

  # The SOAP header can be configured to default to a Hash that gets
  # translated to XML by Gyoku. I would love to remove this feature,
  # so if you rely on it, open a ticket and let me know why you need it.
  config.soap_header = { auth: { username: "admin", password: "secret" } }

end
```

The example above used the global config. Each `Savon::Client` clones the global config
on instantiation to allow different client objects to use a different logger, custom
error handling or any other setting.

Here's an example of how to access the per-client config and change the error handling:

``` ruby
client = Savon.client("http://service.example.com?wsdl")
client.config.raise_errors = false
```

Please note that disabling Savon's logger does not disable logging of any dependant libraries.  
[HTTPI](http://rubygems.org/gems/httpi) for example will continue to log HTTP requests and has
to be configured separately. Here's how you can disable logging for HTTPI:

``` ruby
HTTPI.log = false
```
