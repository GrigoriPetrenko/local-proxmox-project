FROM jenkins/jenkins:lts

USER root

RUN jenkins-plugin-cli --plugins \
  git \
  workflow-aggregator \
  configuration-as-code