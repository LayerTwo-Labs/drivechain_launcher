#!/bin/bash

export RPC_USER="drivechain"
export RPC_PASSWORD="L2L"
export RPC_HOST="127.0.0.1"
export RPC_PORT="18443"
export CONFIG_FILE="$HOME/.drivechain/drivechain.conf"



function drivechain_rpc {
    local method=$1
    local params=$2
    local response=$(curl --user "${RPC_USER}:${RPC_PASSWORD}" -s -d '{"jsonrpc": "1.0", "id":"curltest", "method": "'"${method}"'", "params": ['"${params}"'] }' -H 'Content-Type: application/json' http://${RPC_HOST}:${RPC_PORT}/)
    
    local error=$(echo $response | grep -o '"error":[^,}]*')
    if [ -n "$error" ]; then
        echo "RPC call failed: $error"
        return 1
    else
        local result=$(echo $response | sed -n 's/.*"result":\([^,}]*\).*/\1/p')
        echo "RPC call successful: $result"
        echo $result
        return 0
    fi
}

function startdrivechain {
    if [ $REINDEX -eq 1 ]; then
        echo "drivechain will be reindexed"
        ./mainchain/src/drivechaind --reindex --regtest -conf=$CONFIG_FILE &
    else
        ./mainchain/src/drivechaind --regtest -conf=$CONFIG_FILE &
    fi
    sleep 15s
    
    for i in {1..5}; do
        drivechain_rpc "getblockcount"
        if [ $? -eq 0 ]; then
            echo "drivechain curl successfully started"
            break 
        fi
        echo "Checking if drivechain has started (curl)... attempt $i"
        sleep 5s
    done

    if [ $? -ne 0 ]; then
        echo "ERROR: drivechain failed to start with curl"
        exit 1
    fi
    
}


