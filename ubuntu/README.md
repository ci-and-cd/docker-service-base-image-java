
```bash
docker run --tmpfs=/run --tmpfs=/tmp \
  --cap-add=SYS_ADMIN \
  -e JAVA_PRESERVE_FRAME_POINTER=true \
  -e ENTRYPOINT_CMD="/usr/lib/jvm/java-11-openjdk-amd64/bin/java -cp bin/h2*.jar org.h2.tools.Server -tcp -tcpAllowOthers -tcpPort 9092" \
  -e ENTRYPOINT_WORKDIR="/usr/share/h2" \
  --name=pcp-java-app-bionic \
  -p 44321 -p 44323 -p 9092 \
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
  --privileged \
  --volume=/run/containers/pcp-java-app-bionic:/run/pcp --volume=/sys/fs/cgroup:/sys/fs/cgroup \
  cirepo/service-base-image-java:openjdk-11.0.2-en_US.UTF-8_Etc.UTC-bionic

docker exec -it pcp-java-app-bionic /bin/bash -l

mkdir -p /usr/share/h2/bin
wget -O /usr/share/h2/bin/h2-1.4.199.jar http://central.maven.org/maven2/com/h2database/h2/1.4.199/h2-1.4.199.jar

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
