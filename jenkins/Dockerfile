# Dockerfile
FROM jenkins/jenkins:jdk21

USER root

# Instalar dependencias
RUN apt-get update && \
    apt-get install -y docker.io git curl && \
    rm -rf /var/lib/apt/lists/*

# Cambiar GID del grupo docker al mismo que el host
ARG DOCKER_GID=984
RUN groupmod -g $DOCKER_GID docker && \
    usermod -aG docker jenkins

# Configuración Jenkins
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# Plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY install-plugins.sh /usr/local/bin/install-plugins.sh
RUN chmod +x /usr/local/bin/install-plugins.sh
RUN /usr/local/bin/install-plugins.sh /usr/share/jenkins/ref/plugins.txt

EXPOSE 8080 50000

USER jenkins
