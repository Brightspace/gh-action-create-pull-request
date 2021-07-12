#!/bin/bash
set -eu

GIT_USER_NAME=${1}
GIT_USER_EMAIL=${2}
PULL_REQUEST_LABELS=${3}
COMMIT_MSG_PREFIX=${4}
PULL_REQUEST_TITLE=${5}

if $(git diff-index --quiet HEAD); then
  echo 'No dependencies needed to be updated!'
  exit 0
fi

RUN_LABEL="${GITHUB_WORKFLOW}@${GITHUB_RUN_NUMBER}"
RUN_ENDPOINT="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"

COMMIT_MSG="${COMMIT_MSG_PREFIX}: ${PULL_REQUEST_TITLE} ($(date -I))"
PR_BRANCH=chore/deps-$(date +%s)

git config user.name ${GIT_USER_NAME}
git config user.email ${GIT_USER_EMAIL}
git checkout -b ${PR_BRANCH}

git commit -am "${COMMIT_MSG}"
git push origin ${PR_BRANCH}

DEFAULT_BRANCH=$(curl --silent \
  --url https://api.github.com/repos/${GITHUB_REPOSITORY} \
  --header "authorization: Bearer ${GITHUB_TOKEN}" \
  --header 'content-type: application/json' \
  --fail | jq -r .default_branch)

git fetch origin ${DEFAULT_BRANCH}

PR_NUMBER=$(hub pull-request -b ${DEFAULT_BRANCH} --no-edit | grep -o '[^/]*$')

echo "Created pull request #${PR_NUMBER}."

hub issue update ${PR_NUMBER} -l ${PULL_REQUEST_LABELS} -m "${COMMIT_MSG}" -m "_Generated by [${RUN_LABEL}](${RUN_ENDPOINT})._"
echo "Updated pull request #${PR_NUMBER} (labels: '${PULL_REQUEST_LABELS}')."
