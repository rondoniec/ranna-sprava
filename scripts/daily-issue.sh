#!/usr/bin/env bash
# Daily Ranná Správa issue builder.
# Triggered by ~/Library/LaunchAgents/sk.rannasprava.daily.plist at 21:00 Bratislava time.
# Creates issue for next day's edition + schedules social posts via Buffer for 20:00 next day.

set -e

REPO="/Users/adamhodosi/ProjectX/ranna-sprava"
LOG_DIR="$REPO/scripts/logs"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/daily-$(date +%Y-%m-%d-%H%M).log"

# Cron PATH is minimal — restore homebrew + standard so claude/pwsh/jq/git/node resolve.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export TEMP=/tmp
export TMPDIR=/tmp
export HOME="/Users/adamhodosi"

cd "$REPO"

# Compute next-day metadata for the prompt.
# DAY_OFFSET defaults to +1 (next day). Override via env to backfill / shift, e.g.
# DAY_OFFSET=0 ./scripts/daily-issue.sh — build today's issue (catch-up run after midnight).
OFFSET="${DAY_OFFSET:-+1d}"
NEXT_DATE=$(date -v"$OFFSET" +%Y-%m-%d)
NEXT_WEEKDAY_SK=$(LANG=sk_SK.UTF-8 date -v"$OFFSET" "+%A, %d. %B" 2>/dev/null || date -v"$OFFSET" "+%A, %d. %B")

read -r -d '' PROMPT <<EOF || true
You are running non-interactively as a daily cron job at 21:00 Europe/Bratislava.

Goal: build the next morning's Ranná Správa issue, publish it, then schedule its social posts.

Target date: $NEXT_DATE ($NEXT_WEEKDAY_SK 2026)
Repo root: $REPO (you are already cd'd here)

Phase 1 — issue content (per CLAUDE.md):
1. Read CLAUDE.md and how-we-do-ranna-sprava.md for current workflow.
2. Read the latest issue's vydania/N/index.html as template.
3. Determine next issue number from issues.js (top entry + 1).
4. Fetch news for $NEXT_DATE — Slovak sources (teraz.sk, sme.sk, aktuality.sk). Brave Search MCP available if loaded.
5. Draft Slovak content: 1 main story (Hlavná téma) + 4 quick news (Prehliadka správ) + Číslo dňa + 4 calendar items (Tento týždeň) + Slovo dňa + 3 Súvisiace vydania.
6. Add issue object to top of ISSUES array in issues.js.
7. Create vydania/N/index.html (clone latest as template, replace metadata + content sections + JSON-LD).
8. Create vydania/N/sources.md with all source URLs.
9. Run: pwsh ./update-market-snapshot.ps1 vydania/N/index.html
10. Run: pwsh ./update-weather-snapshot.ps1 vydania/N/index.html
11. Run: pwsh ./check-issue-overlap.ps1 vydania/N/index.html — must report "No duplicate". Rework if not.

Phase 2 — publish + derived assets:
12. Run: pwsh ./publish.ps1 -Issue N
13. Append a "Publish note" entry to how-we-do-ranna-sprava.md.
14. git add -A; git commit -m "Publish Ranná Správa issue N"; git push origin main
15. Run: pwsh ./ping-indexnow.ps1 -Issue N

Phase 3 — social schedule:
16. Use Buffer MCP (already configured in mcpServers) to schedule 3 posts (Twitter, LinkedIn, Facebook) for $NEXT_DATE at 08:00 Europe/Bratislava (= 06:00 UTC summer / 07:00 UTC winter).
17. Buffer channel IDs (per CLAUDE.md):
    - Twitter: 69ce7664af47dacb697f9de4
    - LinkedIn: 69cbd421af47dacb69735039
    - Facebook: 69cd388daf47dacb6979fc5e (REQUIRES metadata.facebook.type="post" in create_post args, else fails)
18. Read post text from the freshly-created vydania/N/social-posts.md (you create it in this run with Slovak post copy for each platform). If absent, draft inline.
19. Use Buffer create_post with: channelId, schedulingType="automatic", mode="customScheduled", text, dueAt (ISO 8601 with +02:00 CEST or +01:00 CET offset). For Facebook also include metadata: { facebook: { type: "post" } }.

Phase 4 — email schedule (Brevo):
20. Run: pwsh ./prepare-brevo-email.ps1 vydania/N/index.html  (generates vydania/N/N-brevo.html)
21. Copy: cp vydania/N/N-brevo.html emails/N-brevo.html
22. Run: bash ./scripts/schedule-brevo-email.sh N "${NEXT_DATE}T08:00:00+02:00"  (schedules Brevo campaign for next-day 08:00 Bratislava). Reads BREVO_API_KEY from env.

Constraints:
- Do not invent news. Only use real sources you fetched.
- Skip podcast embed (out of scope for cron).
- Do not push secrets. Do not modify .claude/.
- If any step fails (overlap, push, schedule), stop, log the error clearly, exit non-zero.

Begin.
EOF

{
  echo "=== daily-issue.sh — start $(date) ==="
  echo "Next date: $NEXT_DATE"
  echo "TZ: $(readlink /etc/localtime)"
  echo ""
  printf '%s' "$PROMPT" | /opt/homebrew/bin/claude \
    --print \
    --model claude-sonnet-4-6 \
    --dangerously-skip-permissions \
    --strict-mcp-config \
    --mcp-config "$REPO/scripts/cron-mcp.json" \
    --add-dir "$REPO"
  RC=$?
  echo ""
  echo "=== claude exit: $RC ==="
  echo "=== daily-issue.sh — end $(date) ==="
  exit $RC
} 2>&1 | tee "$LOG"
