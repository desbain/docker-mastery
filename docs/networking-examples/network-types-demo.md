# Docker Networking — Live Demo Results
## George Awa — Docker Mastery Project

## Networks Created for This Demo

### my-custom-network (bridge, has internet)
```bash
docker network create \
  --driver bridge \
  --subnet 192.168.100.0/24 \
  --gateway 192.168.100.1 \
  my-custom-network
```

### my-internal-network (bridge, NO internet)
```bash
docker network create \
  --driver bridge \
  --internal \
  --subnet 192.168.200.0/24 \
  my-internal-network
```

---

## Containers Used

### net-test-1 — on custom network (has internet)
```bash
docker run -d \
  --name net-test-1 \
  --network my-custom-network \
  alpine sleep 300
```

### net-test-2 — on custom network (same as net-test-1)
```bash
docker run -d \
  --name net-test-2 \
  --network my-custom-network \
  alpine sleep 300
```

### net-isolated — on internal network (NO internet)
```bash
docker run -d \
  --name net-isolated \
  --network my-internal-network \
  alpine sleep 300
```

---

## Proof Results

### Test 1 — DNS Resolution on Custom Network
```bash
docker exec net-test-1 ping -c 3 net-test-2
# Result: 3 packets transmitted, 3 received, 0% packet loss
# net-test-2 resolved to 192.168.100.3 automatically by Docker DNS
```

### Test 2 — Internal Network Blocks Internet
```bash
docker exec net-isolated ping -c 3 8.8.8.8
# Result: 3 packets transmitted, 0 received, 100% packet loss
# PROVED: internal: true completely blocks internet access
```

### Test 3 — Custom Network Has Internet
```bash
docker exec net-test-1 ping -c 3 8.8.8.8
# Result: 3 packets transmitted, 3 received, 0% packet loss
# PROVED: bridge network has full internet access
```

### Test 4 — Different Networks Cannot See Each Other
```bash
docker exec net-test-1 ping -c 2 net-isolated
# Result: ping: bad address 'net-isolated'
# PROVED: containers on different networks are invisible to each other
```

### Test 5 — Bridging Networks Enables Controlled Access
```bash
docker network connect my-internal-network net-test-1
docker exec net-test-1 ping -c 2 net-isolated
# Result: 2 packets transmitted, 2 received, 0% packet loss
# PROVED: connecting a container to both networks bridges them
# This is exactly how taskflow-api works in our Compose stack
```

---

## How This Maps to TaskFlow

If postgres is compromised:
- Cannot make outbound connections to attacker's server
- Cannot download malware
- Cannot exfiltrate data over internet
- Completely trapped on the internal network

---

## To Recreate This Demo

```bash
# Create networks
docker network create --driver bridge --subnet 192.168.100.0/24 --gateway 192.168.100.1 my-custom-network
docker network create --driver bridge --internal --subnet 192.168.200.0/24 my-internal-network

# Start containers
docker run -d --name net-test-1 --network my-custom-network alpine sleep 3600
docker run -d --name net-test-2 --network my-custom-network alpine sleep 3600
docker run -d --name net-isolated --network my-internal-network alpine sleep 3600

# Run the tests
docker exec net-test-1 ping -c 3 net-test-2
docker exec net-isolated ping -c 3 8.8.8.8
docker exec net-test-1 ping -c 3 8.8.8.8
docker exec net-test-1 ping -c 2 net-isolated
docker network connect my-internal-network net-test-1
docker exec net-test-1 ping -c 2 net-isolated

# Clean up when done
docker rm -f net-test-1 net-test-2 net-isolated
docker network rm my-custom-network my-internal-network
```
