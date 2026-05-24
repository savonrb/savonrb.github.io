---
layout: guides
title: "Ruby SOAP Client"
nav_title: "Overview"
description: "Savon is a Ruby SOAP client for WSDL-based integrations. Find installation, examples, API docs, releases, and support links."
permalink: /
savon_version: v2
nav_savon_version: v2
order: -1
---

Savon is a SOAP client for Ruby. It reads a WSDL document, discovers available operations, and handles the conversion between Ruby and XML in both directions. You write Ruby hashes and get Ruby hashes back.

Savon 2.x is the current stable version and requires Ruby 3.0 or later.

## Installation

Add to your Gemfile and run `bundle install`:

``` ruby
gem 'savon', '~> 2.17'
```

## What's in the docs

<div class="home_docs_grid">
  <article class="home_docs_card">
    <h3 class="no_toc"><a href="/version2/soap">SOAP &amp; WSDL</a></h3>
    <p>New to SOAP? Start here. Explains what SOAP is, what a WSDL document contains, how Savon reads it, and what to do when you don't have one.</p>
    <p class="home_docs_links"><a href="/version2/soap">SOAP &amp; WSDL →</a></p>
  </article>

  <article class="home_docs_card">
    <h3 class="no_toc"><a href="/version2/client">Client</a></h3>
    <p>How to create a client from a WSDL URL or file, use the block interface, and list available operations.</p>
    <p class="home_docs_links"><a href="/version2/client">Client →</a></p>
  </article>

  <article class="home_docs_card">
    <h3 class="no_toc"><a href="/version2/globals">Global options</a></h3>
    <p>Options passed to <code>Savon.client</code> that apply to all requests. They cover authentication, logging, SSL, timeouts, response parsing, request building, and transport.</p>
    <p class="home_docs_links"><a href="/version2/globals">Globals →</a></p>
  </article>

  <article class="home_docs_card">
    <h3 class="no_toc"><a href="/version2/globals#authentication">Authentication</a></h3>
    <p>Savon supports HTTP basic, digest, and NTLM authentication, plus WS-Security (WSSE) with username/password, digest, and timestamp.</p>
    <p class="home_docs_links"><a href="/version2/globals#authentication">Authentication →</a></p>
  </article>

  <article class="home_docs_card">
    <h3 class="no_toc"><a href="/version2/requests">Building requests</a></h3>
    <p>How to call an operation and structure the message hash. Local options let you override globals per request and pass raw XML when you need full control.</p>
    <p class="home_docs_links">
      <a href="/version2/requests">Requests →</a>
      <a href="/version2/locals">Local options →</a>
    </p>
  </article>

  <article class="home_docs_card">
    <h3 class="no_toc"><a href="/version2/response">Reading responses</a></h3>
    <p>The response body comes back as a nested Hash with snake_case symbol keys. You can also access raw XML, query with XPath, and inspect the HTTP response directly.</p>
    <p class="home_docs_links"><a href="/version2/response">Response →</a></p>
  </article>

  <article class="home_docs_card">
    <h3 class="no_toc"><a href="/version2/errors">Error handling</a></h3>
    <p>Savon raises on SOAP faults and HTTP errors by default. This page covers the three exception classes, how to read fault details, and how to handle errors manually.</p>
    <p class="home_docs_links"><a href="/version2/errors">Errors →</a></p>
  </article>

  <article class="home_docs_card">
    <h3 class="no_toc"><a href="/version2/debugging">Debugging</a></h3>
    <p>How to enable logging, inspect raw envelopes, filter sensitive values from logs, and diagnose common failures.</p>
    <p class="home_docs_links"><a href="/version2/debugging">Debugging →</a></p>
  </article>

  <article class="home_docs_card">
    <h3 class="no_toc"><a href="/version2/testing">Testing</a></h3>
    <p>Mocking SOAP responses in tests without hitting a real service, using <code>Savon::SpecHelper</code>.</p>
    <p class="home_docs_links"><a href="/version2/testing">Testing →</a></p>
  </article>

  <article class="home_docs_card">
    <h3 class="no_toc"><a href="/version2/observers">Observers</a></h3>
    <p>Hooks into the request-response cycle for custom logging or monitoring.</p>
    <p class="home_docs_links"><a href="/version2/observers">Observers →</a></p>
  </article>

  <article class="home_docs_card">
    <h3 class="no_toc"><a href="/version2/model">Savon::Model</a></h3>
    <p>A module that adds a SOAP client DSL to your own classes.</p>
    <p class="home_docs_links"><a href="/version2/model">Model →</a></p>
  </article>

  <article class="home_docs_card">
    <h3 class="no_toc"><a href="/version2/examples">Examples</a></h3>
    <p>Focused, copy-pasteable snippets for common patterns: key conversion, nested messages, arrays, response navigation, error handling, and more.</p>
    <p class="home_docs_links"><a href="/version2/examples">Examples →</a></p>
  </article>
</div>
