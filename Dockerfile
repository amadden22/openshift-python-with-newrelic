FROM registry.access.redhat.com/rhel7
MAINTAINER Vinod Vydier<vvydier@newrelic.com>

### Add necessary Red Hat repos here
RUN REPOLIST=rhel-7-server-rpms,rhel-7-server-optional-rpms,epel \
### Add your package needs here
    INSTALL_PKGS="python2-pip" && \
    yum update \
    yum -y update-minimal --security --sec-severity=Important --sec-severity=Critical --setopt=tsflags=nodocs \
      --security --sec-severity=Important --sec-severity=Critical && \
    curl -o epel-release-latest-7.noarch.rpm -SL https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
      --retry 5 --retry-max-time 0 -C - && \
    yum -y localinstall epel-release-latest-7.noarch.rpm && rm epel-release-latest-7.noarch.rpm && \
    yum -y install --disablerepo "*" --enablerepo ${REPOLIST} --setopt=tsflags=nodocs ${INSTALL_PKGS} && \
    yum clean all

LABEL name="newrelic-admin-rhel73/python-agent" \
      maintainer="vvydier@newrelic.com" \
      vendor="NewRelic" \
      version="1.0" \
      release="1" \
      summary="Newrelic's Python agent starter image" \
      description="Newrelic's Python agent starter image" \
      url="https://newrelic.com"

### Atomic Help File - Write in Markdown, it will be converted to man format at build time.
### https://github.com/projectatomic/container-best-practices/blob/master/creating/help.adoc
COPY help.1 /

### add licenses to this directory
RUN mkdir -p /licenses
COPY licenses /licenses

#Install the NewRelic Agent
RUN pip install newrelic

#Script to run the Python Agent test 5 times to make sure you get a good reading in the web UI
COPY runit5times.py .

#When you launch the container, it runs the script and then exits
ENTRYPOINT ["newrelic-admin", "run-program"]

#Default environment variables
ENV NEW_RELIC_LOG=stderr \
    NEW_RELIC_LOG_LEVEL=info \
    NEW_RELIC_ENABLED=true

CMD ["python", "runit5times.py"]
