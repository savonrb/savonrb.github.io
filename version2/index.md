---
name: Version 2
url: version2
layout: guides
title: Overview
savon_version: v2
nav_savon_version: v2
---

Savon is a SOAP client for Ruby. It reads a WSDL document, discovers available operations, and handles the conversion between Ruby and XML in both directions. You write Ruby hashes and get Ruby hashes back.

Savon 2.x is the current stable version and requires Ruby 3.0 or later.

## Installation

Add to your Gemfile and run `bundle install`:

``` ruby
gem 'savon', '~> 2.17'
```

## What's in the docs

### SOAP & WSDL

New to SOAP? Start here. Explains what SOAP is, what a WSDL document contains, how Savon reads it, and what to do when you don't have one.

[SOAP & WSDL →](/version2/soap)

### Client

How to create a client from a WSDL URL or file, use the block interface, and list available operations.

[Client →](/version2/client)

### Global options

Options passed to `Savon.client` that apply to all requests. They cover authentication, logging, SSL, timeouts, response parsing, request building, and transport.

[Globals →](/version2/globals)

### Authentication

 Savon supports HTTP basic, digest, and NTLM authentication, plus WS-Security (WSSE) with username/password, digest, and timestamp. See the authentication section of the globals page.

[Authentication →](/version2/globals)

### Building requests

How to call an operation and structure the message hash. Local options let you override globals per request and pass raw XML when you need full control.

[Requests →](/version2/requests) | [Local options →](/version2/locals)

### Reading responses

The response body comes back as a nested Hash with snake_case symbol keys. You can also access raw XML, query with XPath, and inspect the HTTP response directly.

[Response →](/version2/response)

### Error handling

Savon raises on SOAP faults and HTTP errors by default. This page covers the three exception classes, how to read fault details, and how to handle errors manually.

[Errors →](/version2/errors)

### Debugging

How to enable logging, inspect raw envelopes, filter sensitive values from logs, and diagnose common failures.

[Debugging →](/version2/debugging)

### Testing

Mocking SOAP responses in tests without hitting a real service, using `Savon::SpecHelper`.

[Testing →](/version2/testing)

### Observers

Hooks into the request-response cycle for custom logging or monitoring.

[Observers →](/version2/observers)

### Savon::Model

A module that adds a SOAP client DSL to your own classes.

[Model →](/version2/model)

### Examples

Focused, copy-pasteable snippets for common patterns: key conversion, nested messages, arrays, response navigation, error handling, and more.

[Examples →](/version2/examples)

### Changes

Release notes for each version.

[Changes →](/version2/changes)
