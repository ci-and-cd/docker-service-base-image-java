# docker-service-base-image-java

docker-service-base-image-java


Base docker image for Java based services with locale settings

Features:

- remote debug
- jmc
- /opt/ejstatd/ejstatd-1.0.0.jar
- jmxremote
- jprofiler agent
- arthas
- JAVA_OPTS -Duser.language=en -Duser.region=US -Dfile.encoding=UTF-8 -Duser.timezone=Etc/UTC
- CLASSPATH .:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib

Env variables:

- EUREKA_INSTANCE_HOSTNAME
- JAVA_DEBUG_PORT
- JAVA_JMC_ENABLED
- JAVA_JSTATD_RMI_PORT
- JAVA_JSTATD_RH_PORT
- JAVA_JSTATD_RV_PORT
- JAVA_JMX_PORT
- SECURITY_USER_NAME
- SECURITY_USER_PASSWORD

## Java11 OpenJDK

cirepo/java:openjdk-11.0.2-en_US.UTF-8_Etc.UTC-alpine


## Java11 Zulu

cirepo/java:zulu-11.0.2-en_US.UTF-8_Etc.UTC-alpine
