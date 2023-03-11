---
savon_version: v3
title: Logging
layout: default
nav_savon_version: v3
---

Savon 3.0 uses the [Logging](https://github.com/TwP/logging) gem which allows us to use multiple
loggers and easily control them from the outside. Please make sure to read the documentation for
this library in order to customize logging.

Let me give you an example of how you would change the log level and add a `STDOUT` appender to the
root logger. This basically tells all registered loggers to write everything to `STDOUT`.

``` ruby
logger = Logging.logger['root']
logger.add_appenders(Logging.appenders.stdout)
logger.level = :debug
```

While the root logger controls all registered loggers, you can also target any single logger by name.
