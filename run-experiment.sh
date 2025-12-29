#!/bin/bash

# Configuration
URL="http://sms.test.local/sms"
DURATION_SECONDS=180  # Runs for 3 minutes to give good graph data

echo "==================================================="
echo "Starting A4 Continuous Experimentation Load Test"
echo "Hypothesis: Canary UI (v2) drives higher engagement"
echo "==================================================="
echo "Simulating:"
echo " - 90% Users on STABLE (v1) -> Low engagement (Lazy)"
echo " - 10% Users on CANARY (v2) -> High engagement (Hyperactive)"
echo "==================================================="

end_time=$((SECONDS + DURATION_SECONDS))

while [ $SECONDS -lt $end_time ]; do
    
    # --- STABLE TRAFFIC (The "Lazy" Users) ---
    # 9 separate users hit 'stable' ONCE each
    for i in {1..9}; do
        curl -s -X POST "$URL" \
          -H "Cookie: sms-user=stable" \
          -H "Content-Type: application/json" \
          -d '{"sms":"I am a stable user","guess":"ham"}' > /dev/null &
    done

    # --- CANARY TRAFFIC (The "Engaged" Users) ---
    # 1 user hits 'canary', but they click 20 TIMES!
    for i in {1..20}; do
        curl -s -X POST "$URL" \
          -H "Cookie: sms-user=canary" \
          -H "Content-Type: application/json" \
          -d '{"sms":"I LOVE THIS NEW UI","guess":"ham"}' > /dev/null &
    done

    # Wait 1 second before next batch to keep rate steady
    sleep 1
    echo -n "."
done

echo ""
echo "Experiment Complete! Check Grafana 'User Engagement' panel."