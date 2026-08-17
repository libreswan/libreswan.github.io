- Do inventory of logging functions and proposal for cleanup

<!-- -->

- most (if not all?) helper programs need to only log to stdout/stderr,
  so most logging functions are inappropriate.

<!-- -->

- if library functions need to log, they need to send such errors
  upstream, so they do not need to know the logging state (stderr or
  syslog) that is not available in the library