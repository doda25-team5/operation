#!/bin/bash
# Continuous, human-like traffic generator for A4 experiment 

set -u   # fail on undefined vars

# Configuration
URL="${SMS_URL:-http://sms.test.local/sms}"  
DURATION=900   # 15 minutes

# Traffic simulation
# - 20% probability per second - Stable users check messages occasionally (~1-2 per session)
# - 60% probability per second - Canary users are more engaged (~3-4 per session)
STABLE_ENGAGEMENT_RATE=20  
CANARY_ENGAGEMENT_RATE=60 

END_TIME=$((SECONDS + DURATION))

STABLE_SENT=0
CANARY_SENT=0
TOTAL_SENT=0
SECOND=0

echo "=========================================="
echo "Starting A4 Continuous Experiment"
echo "Duration: ${DURATION}s"
echo "Stable users: 9 (low engagement ~${STABLE_ENGAGEMENT_RATE}% activity)"
echo "Canary users: 1 (high engagement ~${CANARY_ENGAGEMENT_RATE}% activity)"
echo "Target URL: $URL"
echo "=========================================="
echo ""

while [ $SECONDS -lt $END_TIME ]; do
  SECOND=$((SECOND + 1))
  STABLE_THIS_SEC=0
  CANARY_THIS_SEC=0

  # -------------------------
  # Stable users (v1) – 90%
  # -------------------------
  for user in {1..9}; do
    if (( RANDOM % 100 < STABLE_ENGAGEMENT_RATE )); then
      if curl -s -o /dev/null -w "%{http_code}" \
        -X POST "$URL" \
        -H "Cookie: sms-user=stable-${user}" \
        -H "Content-Type: application/json" \
        -d "{\"sms\":\"Stable user ${user} message\",\"guess\":\"ham\"}" \
        | grep -q "^200$"; then
          STABLE_SENT=$((STABLE_SENT + 1))
          STABLE_THIS_SEC=$((STABLE_THIS_SEC + 1))
          TOTAL_SENT=$((TOTAL_SENT + 1))
      else
        echo "[WARN] Stable user ${user} request failed"
      fi
    fi
  done

  # -------------------------
  # Canary users (v2) – 10%
  # -------------------------
  if (( RANDOM % 100 < CANARY_ENGAGEMENT_RATE )); then
    if curl -s -o /dev/null -w "%{http_code}" \
      -X POST "$URL" \
      -H "Cookie: sms-user=canary-1" \
      -H "Content-Type: application/json" \
      -d "{\"sms\":\"Canary user engaged!\",\"guess\":\"ham\"}" \
      | grep -q "^200$"; then
        CANARY_SENT=$((CANARY_SENT + 1))
        CANARY_THIS_SEC=$((CANARY_THIS_SEC + 1))
        TOTAL_SENT=$((TOTAL_SENT + 1))
    else
      echo "[WARN] Canary request failed"
    fi
  fi

  # -------------------------
  # Per-second heartbeat
  # -------------------------
  printf "[%4ds] sent this second → stable=%d canary=%d | totals → stable=%d canary=%d total=%d\n" \
    "$SECOND" \
    "$STABLE_THIS_SEC" \
    "$CANARY_THIS_SEC" \
    "$STABLE_SENT" \
    "$CANARY_SENT" \
    "$TOTAL_SENT"

  sleep 1
done

echo ""
echo "=========================================="
echo "Experiment complete."
echo "Stable messages sent: $STABLE_SENT"
echo "Canary messages sent: $CANARY_SENT"
echo "Total messages sent:  $TOTAL_SENT"
echo "=========================================="
