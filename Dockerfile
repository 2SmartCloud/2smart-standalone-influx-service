FROM influxdb:1.7.11

COPY startup_configuration.sh startup_configuration.sh

ENTRYPOINT nohup sh /startup_configuration.sh >> nohup.out & /entrypoint.sh influxd
