FROM openjdk:11-jre-slim

# install SSH server
RUN apt-get update && \
    apt-get install -y openssh-server git && \
    mkdir /var/run/sshd

# create the jenkins user 
RUN useradd -m -d /home/jenkins -s /bin/bash jenkins \
    && echo 'jenkins:jenkinspass' | chpasswd \
    && mkdir -p /home/jenkins/agent /home/jenkins/.ssh \
    && chown -R jenkins:jenkins /home/jenkins

EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]