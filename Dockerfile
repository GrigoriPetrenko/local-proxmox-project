FROM jenkins/jenkins:lts

USER root

RUN jenkins-plugin-cli --plugins \
  git \
  workflow-aggregator \
  configuration-as-code \
  job-dsl \
  workflow-cps \
  workflow-job \
  pipeline-model-definition \
  credentials \
  script-security