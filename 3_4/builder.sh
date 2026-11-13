#!/bin/bash
set -e

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <github-repo> <dockerhub-repo>" >&2
  exit 1
fi

GITHUB_REPO="$1"
DOCKERHUB_REPO="$2"

WORKDIR="$(mktemp -d)"
trap "rm -rf \"$WORKDIR\"" EXIT

git clone "https://github.com/${GITHUB_REPO}" "$WORKDIR/repo"
cd "$WORKDIR/repo"
docker build -t "${DOCKERHUB_REPO}" .
echo "${DOCKER_PASSWORD:-$DOCKER_PWD}" | docker login -u "${DOCKER_USER}" --password-stdin
docker push "${DOCKERHUB_REPO}"
