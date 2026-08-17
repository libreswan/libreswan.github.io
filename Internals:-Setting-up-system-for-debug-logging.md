Systemd journald rate limits logging. If you enable plutodebug logging
you don't get full logs without disabling rate limiting.

## Disable rate limiting in journald

1.  mkdir -p /etc/systemd/journald.conf.d
2.  vi /etc/systemd/journald.conf.d/override.conf

<!-- -->

    [Journal]
    RateLimitInterval=0
    RateLimitBurst=0

1.  systemctl daemon-reload
2.  systemctl restart systemd-journald.service

### Disable rate limiting in rsyslogd

1.  vi /etc/rsyslog.d/local.conf

<!-- -->

    # Disable IMjournal rate limiting
    $IMUXSockRateLimitInterval 0
    $IMJournalRatelimitInterval 0

1.  systemctl restart rsyslogd.service