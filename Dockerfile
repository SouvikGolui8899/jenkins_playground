FROM jenkins/jenkins:2.332.2-jdk11
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/jenkins.yaml
USER root
RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli
RUN apt-get install -y wget vim sshpass
RUN chown -R jenkins:jenkins /var/jenkins_home/

USER jenkins
WORKDIR /var/jenkins_home
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY --chown=jenkins:jenkins jenkins.yaml /usr/share/jenkins/ref/jenkins.yaml
COPY --chown=jenkins:jenkins ssh.qe.tar /usr/share/jenkins/ref/ssh.qe.tar
RUN tar -xf /usr/share/jenkins/ref/ssh.qe.tar -C /usr/share/jenkins/ref
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt