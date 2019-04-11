
```bash
docker run --tmpfs=/run --tmpfs=/tmp \
  --cap-add=SYS_ADMIN \
  -e JAVA_PRESERVE_FRAME_POINTER=true \
  -e ENTRYPOINT_CMD="/usr/lib/jvm/java-11-openjdk-amd64/bin/java -Dparfait.name=acme -javaagent:/usr/share/java/parfait/parfait.jar -jar /usr/share/java/parfait/acme.jar Main" \
  -e ENTRYPOINT_WORKDIR="/usr/share/java/parfait" \
  --name=pcp-java-app-fedora \
  -p 44321 -p 44323 \
  -e JPDA_ADDRESS="*:5005" \
  -p 5005 \
  -e JAVA_JMC_ENABLED=true \
  -e JAVA_FLIGHT_RECORDER_OPTIONS="old-object-queue-size=256" \
  -e JAVA_START_FLIGHT_RECORDING="disk=true,dumponexit=true,filename=/tmp/myrecording.jfr,maxsize=1024m,maxage=1d,name=myrecording,path-to-gc-roots=true,settings=profile" \
  -e JAVA_JMX_PORT=5000 \
  -p 5000 \
  -e JAVA_JPROFILER_CONFIG=/root/.jprofiler11/jprofiler_config.xml -e JAVA_JPROFILER_PATH=/opt/jprofiler11 -e JAVA_JPROFILER_PORT=8849 -e JAVA_JPROFILER_SESSION_ID=110 \
  -p 8849 \
  -e JAVA_JSTATD_RMI_PORT=2222 -e JAVA_JSTATD_RH_PORT=2223 -e JAVA_JSTATD_RV_PORT=2224 \
  -p 2222 -p 2223 -p 2224 \
  --volume=/run/containers/pcp-java-app-fedora:/run/pcp --volume=/sys/fs/cgroup:/sys/fs/cgroup \
  cirepo/service-base-image-java:openjdk-11.0.2-en_US.UTF-8_Etc.UTC-fedora


docker exec -it pcp-java-app-fedora /bin/bash -l




systemctl restart entrypoint
journalctl -f _SYSTEMD_UNIT=entrypoint.service
journalctl _SYSTEMD_UNIT=pmwebd.service
systemctl restart pmwebd
systemctl status pmwebd -l
journalctl -xe
cat /var/log/pcp/pmwebd/pmwebd.log
cat /var/log/pcp/pmcd/pmcd.log
cat /var/log/pcp/pmcd/vector.log

docker run -d \
  --name vector \
  -p 80:80 \
  netflixoss/vector:latest

docker run -d \
  --name vector \
  -p 80:80 \
  netflixoss/vector:v1.3.2
```

If `--volume=/sys/fs/cgroup:/sys/fs/cgroup:ro`
pmwebd.service: Failed to set invocation ID on control group /system.slice (/sys/fs/cgroup/systemd/system.slice)
