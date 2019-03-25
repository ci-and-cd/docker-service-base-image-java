#!/usr/bin/env bash

set -e

if [[ -z ${LOG_PATH+x} ]]; then export LOG_PATH="${HOME}/data/logs"; fi

# Use CMS by default
#JAVA_OPTS="${JAVA_OPTS} -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=75"
# Use G1 by default
#JAVA_OPTS="${JAVA_OPTS} -XX:+UseG1GC"
# -XX:+PrintFlagsFinal will log to console
JAVA_OPTS="${JAVA_OPTS} -XX:-OmitStackTraceInFastThrow -XX:+PrintFlagsFinal";
# http://stackoverflow.com/questions/137212/how-to-solve-performance-problem-with-java-securerandom
JAVA_OPTS="${JAVA_OPTS} -Djava.security.egd=file:/dev/urandom";

# Crash dump & Heap dump
if [[ "${JVM_DUMP_DISABLED}" != "true" ]]; then JAVA_OPTS="${JAVA_OPTS} -XX:ErrorFile=${LOG_PATH}/hs_err_%p.log -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${LOG_PATH}/"; fi

# GC log
# GC log options for Java8
#if [[ "${JVM_GCLOG_DISABLED}" != "true" ]]; then JAVA_OPTS="${JAVA_OPTS} -Xloggc:${LOG_PATH}/gc_%p.log -XX:+PrintGCDateStamps -XX:+PrintGCDetails -XX:+PrintGCApplicationConcurrentTime -XX:+PrintGCApplicationStoppedTime -XX:+PrintGC"; fi
# GC log options for Java 9 and above
# see: https://stackoverflow.com/questions/54144713/is-there-a-replacement-for-the-garbage-collection-jvm-args-in-java-11
# see: https://dzone.com/articles/disruptive-changes-to-gc-logging-in-java-9
# -Xlog:safepoint will log to console and too verbose
if [[ "${JVM_GCLOG_DISABLED}" != "true" ]]; then JAVA_OPTS="${JAVA_OPTS} -Xlog:gc*:file=${LOG_PATH}/gc_%p.log"; fi
if [[ ! -d ${LOG_PATH} ]]; then mkdir -p ${LOG_PATH}; fi

if [[ -n "${SPRING_PROFILES_ACTIVE}" ]]; then JAVA_OPTS="${JAVA_OPTS} -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE}"; fi
export JAVA_TOOL_OPTIONS="${JAVA_OPTS}"

. /opt/java_debug_monitor_profiler.sh

# if command starts with an option, prepend java
if [[ "${1:0:1}" == '-' ]]; then
    set -- java "$@" -jar *-exec.jar
elif [[ "${1:0:1}" != '/' ]]; then
    set -- java -jar *-exec.jar "$@"
fi

exec "$@"
