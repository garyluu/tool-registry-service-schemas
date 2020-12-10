#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
set -u
BRANCH=$(echo "$TRAVIS_BRANCH" | awk '{print tolower($0)}')
BRANCH_PATH="preview/$BRANCH"
mv preview preview2
git config --replace-all remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
git fetch --deepen=50000
git checkout gh-pages
rm -rf preview
mv preview2 preview
git status
if [[ -n "$(git status --porcelain "${BRANCH_PATH}")" && ${TRAVIS_PULL_REQUEST} == "false" ]]; then
  openssl aes-256-cbc -K $encrypted_8ebb1ef83f64_key -iv $encrypted_8ebb1ef83f64_iv -in github_deploy_key.enc -out github_deploy_key -d
  bash scripts/create-table-of-contents.sh
  bash scripts/remove-docs-for-deleted-branches.sh
  git add preview
  git add TableOfContents.md
  rm -rf node_modules
else
  echo "No changes"
  travis_terminate 0;
fi
