#!/usr/bin/env bash
# pre-triage.sh — Strip triage-related labels before the agent runs.
#
# Runs on the host via the harness pre_script mechanism. Ensures every
# triage invocation starts from a clean label baseline, preventing
# mutual-exclusion violations (Story 2, #125).
#
# Required env vars:
#   GITHUB_ISSUE_URL — HTML URL of the issue
#   GH_TOKEN         — GitHub token with issues read/write scope

set -euo pipefail

REPO=$(echo "${GITHUB_ISSUE_URL}" | sed 's|https://github.com/||; s|/issues/.*||')
ISSUE_NUMBER=$(basename "${GITHUB_ISSUE_URL}")

echo "Resetting triage labels on ${REPO}#${ISSUE_NUMBER}"

for label in needs-info ready-to-code duplicate not-ready not-reproducible; do
  gh issue edit "${ISSUE_NUMBER}" --repo "${REPO}" --remove-label "${label}" 2>/dev/null || true
done

echo "Label reset complete."
