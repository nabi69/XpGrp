#!/bin/bash
# Colors
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

# Banner
echo -e "${YELLOW}========================================${NC}"
echo -e "${CYAN}        Welcome to Xp Group INC         ${NC}"
echo -e "${YELLOW}========================================${NC}"

# Timestamp for log file
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOGFILE="network-discovery-$TIMESTAMP.log"

# Target IP to test internet route and ping
TARGET_IP="8.8.8.8"

# Discover default interface
DEFAULT_IF=$(ip route get "$TARGET_IP" 2>/dev/null | awk '/dev/ {for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}')

# Start logging
{
  echo "🕒 Network Discovery Log — $TIMESTAMP"
  echo "========================================"
  echo "🔍 Default route to $TARGET_IP:"
  ip route get "$TARGET_IP"
  echo ""

  if [ -n "$DEFAULT_IF" ]; then
    echo "✅ Default interface to reach the internet: $DEFAULT_IF"
  else
    echo "❌ Could not determine default interface."
  fi
  echo ""

  echo "📡 Interface details for $DEFAULT_IF:"
  ip addr show "$DEFAULT_IF"
  echo ""

  echo "🧭 Full routing table:"
  ip route show
  echo ""

  echo "📶 Ping test to $TARGET_IP (Google DNS):"
  ping -c 4 "$TARGET_IP"
  echo ""
} | tee "$LOGFILE"

echo "📁 Log saved to: $LOGFILE"
