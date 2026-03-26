#!/bin/bash
# Trading engines watchdog - auto-restart if killed

SCRIPT_DIR="$HOME/.openclaw/workspace/trading/scripts"
LOG_DIR="$HOME/.openclaw/workspace/trading/logs"
mkdir -p "$LOG_DIR"

restart_engine() {
    local name=$1
    local script=$2
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting $name..."
    cd "$SCRIPT_DIR" && python3 "$script" >> "$LOG_DIR/${name}.log" 2>&1
}

# Start all engines in background
restart_engine "coinbase_momentum" "coinbase_momentum.py" &
sleep 2
restart_engine "polymarket_sol15m" "polymarket_sol15m.py" &
sleep 2
restart_engine "sniper_auto" "sniper_auto.py" &

# Monitor and restart
while true; do
    sleep 30
    
    # Check Coinbase
    if ! pgrep -f "coinbase_momentum.py" > /dev/null; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Coinbase died, restarting..." >> "$LOG_DIR/watchdog.log"
        restart_engine "coinbase_momentum" "coinbase_momentum.py" &
    fi
    
    # Check BTC-15M
    if ! pgrep -f "polymarket_btc15m.py" > /dev/null; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] BTC-15M died, restarting..." >> "$LOG_DIR/watchdog.log"
        restart_engine "polymarket_btc15m" "polymarket_btc15m.py" &
    fi
    
    # Check ETH-15M
    if ! pgrep -f "polymarket_eth15m.py" > /dev/null; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ETH-15M died, restarting..." >> "$LOG_DIR/watchdog.log"
        restart_engine "polymarket_eth15m" "polymarket_eth15m.py" &
    fi
    
    # Check SOL-15M
    if ! pgrep -f "polymarket_sol15m.py" > /dev/null; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] SOL-15M died, restarting..." >> "$LOG_DIR/watchdog.log"
        restart_engine "polymarket_sol15m" "polymarket_sol15m.py" &
    fi
    
    # Check Sniper Auto
    if ! pgrep -f "sniper_auto.py" > /dev/null; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Sniper Auto died, restarting..." >> "$LOG_DIR/watchdog.log"
        restart_engine "sniper_auto" "sniper_auto.py" &
    fi
done
