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
    
    # Check if drivechain has started using curl
    for i in {1..5}; do
        drivechain_rpc "getblockcount" > /dev/null
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

function test_mining {
    # mining a single block and generate new address
    echo "Testing mining a single block..."
    drivechain_rpc "generatetoaddress" "1,\"$(drivechain_rpc "getnewaddress")\""
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to mine a single block"
        exit 1
    fi
    echo "Successfully mined a single block"

    # Test mining multiple blocks
    echo "Testing mining 100 blocks..."
    drivechain_rpc "generatetoaddress" "100,\"$(drivechain_rpc "getnewaddress")\""
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to mine 100 blocks"
        exit 1
    fi
    echo "Successfully mined 100 blocks"

    # mining with insufficient balance
    echo "Testing mining with insufficient balance..."
    drivechain_rpc "sendtoaddress" "\"$(drivechain_rpc "getnewaddress")\", 1000000"
    if [ $? -eq 0 ]; then
        echo "ERROR: Mining transaction succeeded with insufficient balance, which is unexpected"
        exit 1
    fi
    echo "Correctly handled insufficient balance case"

    # mining to an invalid address
    echo "Testing mining to an invalid address..."
    drivechain_rpc "generatetoaddress" "1,\"invalidaddress\""
    if [ $? -eq 0 ]; then
        echo "ERROR: Mining transaction succeeded with invalid address, which is unexpected"
        exit 1
    fi
    echo "Correctly handled invalid address case"

    # mining with a low fee
    echo "Testing mining with a low fee..."
    drivechain_rpc "sendtoaddress" "\"$(drivechain_rpc "getnewaddress")\", 0.00001"
    if [ $? -ne 0 ]; then
        echo "ERROR: Mining transaction failed with a low fee"
        exit 1
    fi
    echo "Successfully handled low fee case"

    echo "All mining tests passed"
}

