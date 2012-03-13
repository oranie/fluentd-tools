my $app = sub {
    my $env = shift;
    my $body = <<"EOF";
    <source>
      type tail
      format \/^(?<XFF-host>[^ ]*) (?<host>[^ ]*) [^ ]* (?<user>[^ ]*) \\[(?<time>[^\\]]*)\\] "(?<method>\\S+)(?: +(?<path>[^ ]*) +\\S*)?" (?<status>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\\"]*)" "(?<agent>[^\\"]*)" (?<response_time>[^ ]*))?\$\/
      time_format %d/%b/%Y:%H:%M:%S %z
      path /var/log/httpd/access_log_sym
      tag apache.access.$env->{REMOTE_ADDR}
      pos_file /var/tmp/access.log.pos
    </source>
EOF

    return [
        200,
        [ "Content-Type", "text/plain" ],
        [ "$body" ],
    ];
};
