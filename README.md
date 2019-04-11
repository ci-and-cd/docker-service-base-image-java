# docker-service-base-image-java

docker-service-base-image-java


Base docker image for Java based services with locale settings

Features:

- remote debug
- jmc
- /opt/ejstatd/ejstatd-1.0.0.jar
- jmxremote

- jprofiler agent
    /opt/jprofiler11

- jstack-profiler
    /opt/jstack-profiler

- Performance Co-Pilot (PCP) and Netflix vector with CPU Flame Graphs support
    Limitation:
    centos, fedora and ubuntu images only, alpine is not supported
    Docker containers share kernel with hosts.
    Linux perf tool requires a kernel version same as debuginfo/dbgsym in the container.

- arthas
    Run /usr/local/arthas/as.sh

- JAVA_OPTS="-Duser.language=en -Duser.region=US -Dfile.encoding=UTF-8 -Duser.timezone=Etc/UTC"


Env variables:

- EUREKA_INSTANCE_HOSTNAME
    java.rmi.server.hostname (use ip address of eth0 if absent) and host name of spring-cloud applications

- JAVA_JMC_ENABLED
    Caution:
    FlightRecorder is commercial feature
    see: https://stackoverflow.com/questions/53882496/openjdk-jdk11-not-having-jmc-java-mission-controller-flightrecorder/53931362#53931362
    [Fetching and Building OpenJDK Mission Contro](http://hirt.se/blog/?p=947)
    
    JMC6 (For java8 java9 and older, can not record on java10 and newer) Eclipse update sites
    see: http://download.oracle.com/technology/products/missioncontrol/updatesites/base/6.0.0/eclipse/
    or https://download.oracle.com/technology/products/missioncontrol/updatesites/supported/6.0.0/eclipse/
    
    JMC7 (For java10 and newer)
    Build JMC7 see: http://hirt.se/blog/?tag=jdk-mission-control-7
    Official Early Access (removed by oracle) see page archive: http://web.archive.org/web/20181107052849/https://jdk.java.net/jmc/
    
- JAVA_FLIGHT_RECORDER_OPTIONS
    e.g. 'old-object-queue-size=256'
- JAVA_START_FLIGHT_RECORDING
    e.g. 'disk=true,dumponexit=true,filename=/tmp/myrecording.jfr,maxsize=1024m,maxage=1d,name=myrecording,path-to-gc-roots=true,settings=profile'

- JAVA_JMX_PORT=5000
    JConsole connect to this port
    [Jconsole Dock Launcher for Mac OSX](https://256stuff.com/gray/docs/misc/jconsole_launcher_mac_osx/)
    
    VisualVM connect to this port (JMX connection)
    Starting from Oracle JDK 9, Java VisualVM has moved to the GraalVM
    [Download VisualVM standalone distribution at GitHub](https://visualvm.github.io/download.html)
    
    JMC (Java Mission Control) connect to this port (JMX connection)

- JAVA_PRESERVE_FRAME_POINTER=false
    see: http://getvector.io/docs/cpu-flame-graphs.html
    see: http://www.brendangregg.com/FlameGraphs/cpuflamegraphs.html

- JAVA_JPROFILER_CONFIG=${HOME}/.jprofiler11/jprofiler_config.xml
- JAVA_JPROFILER_PATH
    Optional, default: /opt/jprofiler
- JAVA_JPROFILER_PORT=8849
    Optional, offline mode if absent
- JAVA_JPROFILER_SESSION_ID
    A valid session id can be found in ~/.jprofiler11/jprofiler_config.xml 

- JAVA_JSTATD_RMI_PORT=2222
    VisualVM connect to this port (jstatd connection)
- JAVA_JSTATD_RH_PORT=2223
- JAVA_JSTATD_RV_PORT=2224
    Entry point will launch a separate ejstatd process (if enabled - all 3 ports are specified) alongside the java application process

- JPDA_ADDRESS=*:5005
    Attach IntelliJ IDEA debugger to a running Java process
    see: https://stackoverflow.com/questions/21114066/attach-intellij-idea-debugger-to-a-running-java-process
- JPDA_SERVER=y
- JPDA_SUSPEND=n
- JPDA_TRANSPORT=dt_socket

- SPRING_SECURITY_USER_NAME=user
    Username for JMX (writen in com.sun.management.jmxremote.password.file) and spring-boot (with spring-security) applications
- SPRING_SECURITY_USER_PASSWORD=changeit
    Password for JMX (writen in com.sun.management.jmxremote.password.file) and spring-boot (with spring-security) applications

## Java11 OpenJDK

cirepo/service-base-image-java:openjdk-11.0.2-en_US.UTF-8_Etc.UTC-alpine
cirepo/service-base-image-java:openjdk-11.0.2-en_US.UTF-8_Etc.UTC-bionic
cirepo/service-base-image-java:openjdk-11.0.2-en_US.UTF-8_Etc.UTC-centos
cirepo/service-base-image-java:openjdk-11.0.2-en_US.UTF-8_Etc.UTC-fedora


## Java11 Zulu

cirepo/service-base-image-java:zulu-11.0.2-en_US.UTF-8_Etc.UTC-alpine


### References

https://dl.bintray.com/pcp/
https://github.com/binarybrian/flamegraphs


Build on a node (172.17.8.101) of vagrant based k8s cluster (flannel network 172.33/16)
```bash
netstat -nr
sudo route -n delete -net 172.33/16
sudo route -n add    -net 172.33/16 172.17.8.101

rsync -avz -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $(pwd)/../kubernetes-vagrant-centos-cluster/.vagrant/machines/node1/virtualbox/private_key" \
  --progress $(pwd)/docker-service-base-image-java vagrant@172.17.8.101:/home/vagrant
```

