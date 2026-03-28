#!/system/bin/sh
# post-fs-data.sh - Network optimization script

set -e

echo "Applying network optimizations..."

# Optimize network stack
echo "Optimizing network stack..."
# Increase TCP buffer sizes
sysctl -w net.core.rmem_max=16777216
sysctl -w net.core.wmem_max=16777216
sysctl -w net.core.rmem_default=16777216
sysctl -w net.core.wmem_default=16777216
sysctl -w net.core.optmem_max=16777216

# Optimize TCP settings
sysctl -w net.ipv4.tcp_fastopen=3
sysctl -w net.ipv4.tcp_slow_start_after_idle=0
sysctl -w net.ipv4.tcp_tw_reuse=1
sysctl -w net.ipv4.tcp_fin_timeout=30
sysctl -w net.ipv4.tcp_keepalive_time=1200
sysctl -w net.ipv4.tcp_keepalive_probes=3
sysctl -w net.ipv4.tcp_keepalive_intvl=15
sysctl -w net.ipv4.tcp_max_syn_backlog=4096
sysctl -w net.ipv4.tcp_max_tw_buckets=5000
sysctl -w net.ipv4.tcp_window_scaling=1
sysctl -w net.ipv4.tcp_sack=1
sysctl -w net.ipv4.tcp_dsack=1

# Optimize UDP settings
sysctl -w net.ipv4.udp_mem=16777216 16777216 16777216
sysctl -w net.ipv4.udp_rmem_min=8192
sysctl -w net.ipv4.udp_wmem_min=8192

# Optimize routing
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.conf.all.forwarding=1
sysctl -w net.ipv4.conf.default.forwarding=1

# Optimize DNS resolution
echo "Optimizing DNS resolution..."
# Set fast DNS servers
if [ -f "/system/etc/resolv.conf" ]; then
    echo "nameserver 8.8.8.8" > /system/etc/resolv.conf
    echo "nameserver 8.8.4.4" >> /system/etc/resolv.conf
    echo "nameserver 1.1.1.1" >> /system/etc/resolv.conf
fi

# Optimize DNS caching
settings put global dns_caching_enabled 1 2>/dev/null
settings put global dns_cache_size 1000 2>/dev/null
settings put global dns_cache_ttl 3600 2>/dev/null # 1 hour

# Optimize connection management
echo "Optimizing connection management..."
# Increase maximum number of connections
sysctl -w net.core.somaxconn=4096
sysctl -w net.ipv4.tcp_max_syn_backlog=4096
sysctl -w net.ipv4.ip_local_port_range="1024 65535"

# Optimize network buffer settings
sysctl -w net.core.netdev_max_backlog=4096
sysctl -w net.core.flow_limit_count=1024

# Optimize Wi-Fi settings
echo "Optimizing Wi-Fi settings..."
# Enable Wi-Fi optimization
settings put global wifi_connected_mac_randomization_enabled 1 2>/dev/null
settings put global wifi_scan_throttle_enabled 1 2>/dev/null
settings put global wifi_sleep_policy 2 2>/dev/null # Never

# Optimize mobile data settings
echo "Optimizing mobile data settings..."
# Enable mobile data optimization
settings put global mobile_data_always_on 1 2>/dev/null
settings put global mobile_data_prefer_5g 1 2>/dev/null

# Optimize VPN settings
echo "Optimizing VPN settings..."
# Enable VPN optimization
settings put global vpn_on_idle 1 2>/dev/null

# Optimize network security
echo "Optimizing network security..."
# Enable TLS 1.3
settings put global tls_version_min 103 2>/dev/null # TLS 1.3

# Optimize network latency
echo "Optimizing network latency..."
# Enable BBR congestion control if available
if grep -q "bbr" /proc/sys/net/ipv4/tcp_available_congestion_control; then
    sysctl -w net.ipv4.tcp_congestion_control=bbr
fi

# Optimize network throughput
echo "Optimizing network throughput..."
# Enable TCP pacing
if [ -f "/proc/sys/net/ipv4/tcp_pacing_ca_ratio" ]; then
    sysctl -w net.ipv4.tcp_pacing_ca_ratio=120
    sysctl -w net.ipv4.tcp_pacing_rate=4194304 # 4MB/s
fi

echo "Network optimizations applied successfully!"
