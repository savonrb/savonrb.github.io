---
savon_version: v2
order: 11
title: Changes
layout: guides
nav_savon_version: v2
---

A probably incomplete list of changes to help you migrate your application. Let me know if you think there's
something missing.

#### Savon.config

Was removed to better support concurrent usage and allow to use Savon in multiple different
configurations in a single project.

#### Logger

Was replaced with Ruby's standard Logger. The custom Logger was removed for simplicity. You can
still set the global `:log_level` and `:filters` options or active `:pretty_print_xml`.

#### Hooks

Are no longer supported. The implementation was way too complex and still didn't properly solve the
problem of serving as a mock-helper for the [Savon::Spec](http://rubygems.org/gems/savon_spec) gem. If you used
them for any other purpose, please open an issue and we may find a better solution.

#### Nori

Was updated to remove global state. All Nori 2.0 options are now encapsulated and can be configured
through Savon's options. This allows to use Nori in multiple different configurations in a project that uses Savon.

#### Gyoku

Was also updated to remove global state. All Gyoku 1.0 options are encapsulated and can be configured
through Savon. Instead of `Gyoku.convert_symbols_to`, please use the global `:convert_request_keys_to` option.

#### HTTPI

Was updated to version 2 which comes with [support for EM-HTTPRequest](https://github.com/savonrb/httpi/pull/40).

#### NTLM authentication

Support will probably be added in the next version. This really needs some good specs
and integration tests first.

#### WSSE signature

Was not covered with specs and has been removed. If anyone uses this and wants to provide a
properly tested implementation, please talk to me.

#### response[]

The Hash-like read-access to the response was removed.

#### Savon::SOAP::Fault

Was renamed to `Savon::SOAPFault`.

#### Savon::HTTP::Error

Was renamed to `Savon::HTTPError`.

#### Savon::SOAP::InvalidResponseError

Was renamed to `Savon::InvalidResponseError`.
