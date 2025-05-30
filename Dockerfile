# Dockerfile for your SSH‐based Jenkins agent

FROM debian:bookworm-slim

# install the default headless JRE, SSH server, and git
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      default-jre-headless \
      openssh-server \
      git && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /var/run/sshd

# create the jenkins user and workspace
RUN useradd -m -d /home/jenkins -s /bin/bash jenkins \
    && echo 'jenkins:jenkinspass' | chpasswd \
    && mkdir -p /home/jenkins/agent /home/jenkins/.ssh \
    && chown -R jenkins:jenkins /home/jenkins

EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]