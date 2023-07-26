#! /bin/sh
# wait until influxd start
while ! influx  -username "$INFLUXDB_ADMIN_USER" \
                -password "$INFLUXDB_ADMIN_PASSWORD" \
                -execute "SHOW RETENTION POLICIES ON \"$INFLUXDB_DB\"" >/dev/null 2>&1; \
do echo "sleep"; sleep 1; done 
echo "ALTER RETENTION POLICY autogen ON $INFLUXDB_DB DURATION ${ROTATION_DAYS:-90}d SHARD DURATION 1d DEFAULT;";
# write influxd start time point because influx have some issues with restoring backup which has database with empty measurement
influx  -username "$INFLUXDB_ADMIN_USER" \
        -password "$INFLUXDB_ADMIN_PASSWORD" \
        -execute "INSERT timelines,topic=influx_startup_time number=$(date '+%s')" \
        -database="$INFLUXDB_DB"
# update retention policy
if influx -username "$INFLUXDB_ADMIN_USER" \
          -password "$INFLUXDB_ADMIN_PASSWORD" \
          -execute "ALTER RETENTION POLICY autogen ON $INFLUXDB_DB DURATION ${ROTATION_DAYS:-90}d SHARD DURATION 1d DEFAULT;"; then
  echo "ok"
else
  echo "Cannot ALTER RETENTION POLICY";
  pkill influxd;
fi
