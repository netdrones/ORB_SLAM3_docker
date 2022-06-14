GIT_ORG ?= netdrones
# YOu will want to change these depending on the image and the org
REPO ?= netdrones

# Container registry user name for limactl
REPO_USER ?= richt

include lib/include.docker.mk
include lib/include.mk
