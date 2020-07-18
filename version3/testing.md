---
savon_version: v3
title: Testing
layout: default
nav: nav_versions.md
nav_savon_version: v3
---

Be aware, that Savon 3.0 does not ship with any built-in support for mock-based testing!

One reason for this is that I would highly encourage you to write integration tests instead
of relying on testing only a part of the interaction based on some fixtures. From my experience,
it's crucial to have integration tests anyway, so why not start with them?

The second reason for this change is that I would like to minimize our efforts on problems
that are just somehow related to this library so we can main focus on the SOAP and WSDL part.

You don't need any special tools for mocking Savon in your unit tests. Just use your favourite
mocking library and treat it like a blackbox.
