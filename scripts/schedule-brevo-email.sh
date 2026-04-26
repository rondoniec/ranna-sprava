#!/usr/bin/env bash
# Schedule Brevo email campaign for a published issue.
#
# Usage:
#   BREVO_API_KEY=... ./scripts/schedule-brevo-email.sh <issue-number> <iso8601-time>
#
# Example:
#   ./scripts/schedule-brevo-email.sh 88 2026-04-27T08:00:00+02:00
#
# Reads:
#   - emails/[N]-brevo.html  (campaign body)
#   - issues.js              (title for subject)
#
# Requires env: BREVO_API_KEY
# Sender, list IDs hardcoded below (change here if Brevo account changes).

set -e

ISSUE="${1:?usage: schedule-brevo-email.sh <issue> <iso8601>}"
WHEN="${2:?usage: schedule-brevo-email.sh <issue> <iso8601>}"

if [ -z "$BREVO_API_KEY" ]; then
  echo "ERROR: BREVO_API_KEY not set" >&2
  exit 2
fi

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HTML_FILE="$REPO/emails/${ISSUE}-brevo.html"

if [ ! -f "$HTML_FILE" ]; then
  echo "ERROR: $HTML_FILE not found — run prepare-brevo-email.ps1 first" >&2
  exit 3
fi

# Pull title for issue from issues.js (matches: number: N, ... title: "...")
TITLE=$(node -e "
  const fs = require('fs');
  const src = fs.readFileSync('$REPO/issues.js', 'utf8');
  const re = new RegExp('number:\\\\s*$ISSUE,[\\\\s\\\\S]*?title:\\\\s*\"((?:[^\"\\\\\\\\]|\\\\\\\\.)+)\"');
  const m = src.match(re);
  if (!m) { console.error('issue $ISSUE not found in issues.js'); process.exit(4); }
  process.stdout.write(m[1].replace(/\\\\\"/g, '\"'));
")

if [ -z "$TITLE" ]; then
  echo "ERROR: could not parse title for issue $ISSUE from issues.js" >&2
  exit 4
fi

# Truncate subject to 78 chars (Brevo soft limit) — keep on word boundary
SUBJECT_FULL="Ranná Správa #${ISSUE} — ${TITLE}"
if [ ${#SUBJECT_FULL} -gt 78 ]; then
  SUBJECT="${SUBJECT_FULL:0:75}..."
else
  SUBJECT="$SUBJECT_FULL"
fi

# Sender + recipient list (Brevo IDs from /v3/senders + /v3/contacts/lists)
SENDER_NAME="Ranná Správa"
SENDER_EMAIL="newsletter@rannasprava.sk"
LIST_ID=2

echo "scheduling campaign:"
echo "  issue:    #$ISSUE"
echo "  subject:  $SUBJECT"
echo "  due:      $WHEN"
echo "  sender:   $SENDER_NAME <$SENDER_EMAIL>"
echo "  list:     $LIST_ID"

PAYLOAD=$(jq -n \
  --arg name "Ranná Správa #${ISSUE} — automated $(date -u +%Y%m%dT%H%M%SZ)" \
  --arg subject "$SUBJECT" \
  --arg sender_name "$SENDER_NAME" \
  --arg sender_email "$SENDER_EMAIL" \
  --rawfile html "$HTML_FILE" \
  --argjson list "$LIST_ID" \
  --arg when "$WHEN" \
  '{
    name: $name,
    subject: $subject,
    sender: { name: $sender_name, email: $sender_email },
    htmlContent: $html,
    recipients: { listIds: [$list] },
    scheduledAt: $when,
    inlineImageActivation: false
  }')

RESPONSE=$(curl -sS -X POST https://api.brevo.com/v3/emailCampaigns \
  -H "api-key: $BREVO_API_KEY" \
  -H "Content-Type: application/json" \
  -H "accept: application/json" \
  -d "$PAYLOAD")

ID=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('id',''))" 2>/dev/null || true)

if [ -n "$ID" ]; then
  echo "OK: campaign $ID scheduled for $WHEN"
else
  echo "ERROR: Brevo response: $RESPONSE" >&2
  exit 5
fi
