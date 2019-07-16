#!/usr/bin/env bash

set -e

JAVA_VERSION=$(${JAVA_HOME}/bin/java -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F. '{print $1"."$2}')
(>&2 echo JAVA_VERSION ${JAVA_VERSION})

IS_ORACLE_JAVA="false"
if [[ $(${JAVA_HOME}/bin/java -version 2>&1) == *"Java(TM)"* ]]; then IS_ORACLE_JAVA="true"; fi
IS_OPENJDK="false"
if [[ $(${JAVA_HOME}/bin/java -version 2>&1) == *"OpenJDK"* ]]; then IS_OPENJDK="true"; fi
(>&2 echo IS_ORACLE_JAVA ${IS_ORACLE_JAVA} IS_OPENJDK ${IS_OPENJDK})

PSEUDO=""
if [[ $EUID -ne 0 ]]; then
  PSEUDO="sudo "
fi

${PSEUDO}bash ${HOME}/expose_proc_environ.sh "1"
. /tmp/proc_1_environ

if [[ -n ${JRE_HOME} ]]; then export PATH="${JRE_HOME}/bin:${PATH}"; fi
if (( $(echo "${JAVA_VERSION} > 8.0" | bc -l) )); then
    if [[ -z "${JAVA_ADD_MODULES}" ]]; then export JAVA_ADD_MODULES="ALL-SYSTEM"; fi
fi
if [[ -n ${JAVA_HOME} ]]; then export PATH="${JAVA_HOME}/bin:${PATH}"; fi
if [[ -z ${LOG_PATH+x} ]]; then export LOG_PATH="${HOME}/data/logs"; fi
${PSEUDO}mkdir -p ${LOG_PATH}
${PSEUDO}chown -R ${USER:-ubuntu}:${USER:-ubuntu} ${LOG_PATH}
${PSEUDO}chmod 777 ${LOG_PATH}

# Use CMS by default
#JAVA_OPTS="${JAVA_OPTS} -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=75"
# Use G1 by default
#JAVA_OPTS="${JAVA_OPTS} -XX:+UseG1GC"
# -XX:+PrintFlagsFinal will log to console
JAVA_OPTS="${JAVA_OPTS} -XX:-OmitStackTraceInFastThrow -XX:+PrintFlagsFinal";
# http://stackoverflow.com/questions/137212/how-to-solve-performance-problem-with-java-securerandom
JAVA_OPTS="${JAVA_OPTS} -Djava.security.egd=file:/dev/urandom";

# Crash dump & Heap dump
if [[ "${JVM_DUMP_DISABLED}" != "true" ]]; then JAVA_OPTS="${JAVA_OPTS} -XX:ErrorFile=${LOG_PATH}/hs_err_%p.log -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${LOG_PATH}/heapdump.hprof"; fi

# GC log
if (( $(echo "${JAVA_VERSION} > 8.0" | bc -l) )); then
    # GC log options for Java 9 and above
    # see: https://stackoverflow.com/questions/54144713/is-there-a-replacement-for-the-garbage-collection-jvm-args-in-java-11
    # see: https://dzone.com/articles/disruptive-changes-to-gc-logging-in-java-9
    # -Xlog:safepoint will log to console and too verbose
    if [[ "${JVM_GCLOG_DISABLED}" != "true" ]]; then
        if [[ "${JVM_GCLOG_DEBUG:-false}" == "true" ]]; then
            JAVA_OPTS="${JAVA_OPTS} -Xlog:gc*=debug:file=${LOG_PATH}/gc_%p.log:utctime,uptime,tid,level:filecount=10,filesize=128m";
        else
            JAVA_OPTS="${JAVA_OPTS} -Xlog:gc*:file=${LOG_PATH}/gc_%p.log:utctime,uptime,tid,level:filecount=10,filesize=128m";
        fi
    fi
else
    # GC log options for Java8
    if [[ "${JVM_GCLOG_DISABLED}" != "true" ]]; then JAVA_OPTS="${JAVA_OPTS} -Xloggc:${LOG_PATH}/gc_%p.log -XX:+PrintGCDateStamps -XX:+PrintGCDetails -XX:+PrintGCApplicationConcurrentTime -XX:+PrintGCApplicationStoppedTime -XX:+PrintGC"; fi
fi

if [[ ! -d ${LOG_PATH} ]]; then mkdir -p ${LOG_PATH}; fi

if [[ -n "${SPRING_PROFILES_ACTIVE}" ]]; then JAVA_OPTS="${JAVA_OPTS} -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE}"; fi

. /opt/java_debug_monitor_profiler.sh
if [[ "${JAVA_PRESERVE_FRAME_POINTER}" == "true" ]]; then
    ${PSEUDO}chmod -R 777 /var/lib/pcp
    #(>&2 echo systemctl restart pmcd)
    #${PSEUDO}systemctl restart pmcd
    # pmwebd needs SYS_ADMIN and --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro
    #(>&2 echo systemctl restart pmwebd)
    #${PSEUDO}systemctl restart pmwebd
    #(>&2 echo systemctl restart pmlogger)
    #${PSEUDO}systemctl restart pmlogger
    if [[ ! -f /var/lib/pcp/pmdas/vector/help.dir ]] && [[ -f /run/pcp ]] && [[ -f /sys/fs/cgroup ]]; then
        (>&2 echo install pmdas-vector)
        (>&2 cd /var/lib/pcp/pmdas/vector; echo -e 'b\n' | ${PSEUDO}./Install)
    fi
fi

if (( $(echo "${JAVA_VERSION} > 8.0" | bc -l) )); then
    JAVA_OPTS="--illegal-access=permit ${JAVA_OPTS}";
    if [[ -n "${JAVA_ADD_MODULES}" ]]; then JAVA_OPTS="--add-modules=${JAVA_ADD_MODULES} ${JAVA_OPTS}"; fi;
    if [[ -n "${JAVA_ADD_EXPORTS}" ]]; then JAVA_ADD_EXPORTS="--add-exports java.base/jdk.internal.loader=ALL-UNNAMED --add-exports java.base/sun.security.ssl=ALL-UNNAMED"; fi;
    JAVA_OPTS="${JAVA_ADD_EXPORTS} ${JAVA_OPTS}";
    if [[ -n "${JAVA_ADD_OPENS}" ]]; then JAVA_ADD_OPENS="--add-opens java.base/jdk.internal.loader=ALL-UNNAMED --add-opens java.base/sun.security.ssl=ALL-UNNAMED"; fi;
    JAVA_OPTS="${JAVA_ADD_OPENS} ${JAVA_OPTS}";
fi
export JAVA_TOOL_OPTIONS="${JAVA_OPTS}"


if [[ -z "${ENTRYPOINT_WORKDIR}" ]]; then
    if [[ $EUID -ne 0 ]]; then ENTRYPOINT_WORKDIR="/home/${USER:-ubuntu}"; else ENTRYPOINT_WORKDIR="/root"; fi
fi
if [[ -z "${ENTRYPOINT_CMD}" ]]; then ENTRYPOINT_CMD="$@"; fi
(>&2 echo exec ${ENTRYPOINT_CMD})
cd ${ENTRYPOINT_WORKDIR}

EXECUTABLE_FOUND=""
# see: https://stackoverflow.com/questions/6363441/check-if-a-file-exists-with-wildcard-in-shell-script
for f in *-exec.jar; do
    [[ -e "$f" ]] && (>&2 echo "$f do exist") || (>&2 echo "*-exec.jar do not exist")
    EXECUTABLE_FOUND="$f"
    break
done

# if command starts with an option, prepend java
if [[ -z "${ENTRYPOINT_CMD}" ]]; then
    if [[ -n "${EXECUTABLE_FOUND}" ]]; then
        ENTRYPOINT_CMD="java -jar ${EXECUTABLE_FOUND}"
    else
        ENTRYPOINT_CMD="sleep infinity"
    fi
elif [[ "${ENTRYPOINT_CMD:0:1}" == '-' ]]; then
    ENTRYPOINT_CMD="java ${ENTRYPOINT_CMD} -jar ${EXECUTABLE_FOUND}"
elif [[ "${ENTRYPOINT_CMD:0:1}" != '/' ]]; then
    ENTRYPOINT_CMD="java -jar ${EXECUTABLE_FOUND} ${ENTRYPOINT_CMD}"
fi

(>&2 echo exec ${ENTRYPOINT_CMD})
exec ${ENTRYPOINT_CMD}
