---
savon_version: v1
order: 7
title: Troubleshooting
layout: default
nav_savon_version: v1
---

**When Savon can't read the available actions from a WSDL**

``` ruby
client.wsdl.soap_actions  # => []
```

Check if the WSDL uses imports to separate parts of the service description into multiple files.
If that's the case, then [Savon's WSDL parser](https://github.com/savonrb/wasabi) might not be able
to work as expected. This is a known and rather complicated issue on top of my todo list.
