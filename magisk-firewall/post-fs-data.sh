#!/system/bin/sh
# post-fs-data.sh - Firewall implementation script

set -e

echo "Applying firewall settings..."

# Load necessary kernel modules
echo "Loading kernel modules..."
# Load iptables modules
insmod /system/lib/modules/iptable_filter.ko 2>/dev/null
insmod /system/lib/modules/iptable_nat.ko 2>/dev/null
insmod /system/lib/modules/iptable_mangle.ko 2>/dev/null
insmod /system/lib/modules/iptable_raw.ko 2>/dev/null
insmod /system/lib/modules/ip_tables.ko 2>/dev/null
insmod /system/lib/modules/ip6_tables.ko 2>/dev/null
insmod /system/lib/modules/xt_tcpudp.ko 2>/dev/null
insmod /system/lib/modules/xt_state.ko 2>/dev/null
insmod /system/lib/modules/xt_multiport.ko 2>/dev/null
insmod /system/lib/modules/xt_limit.ko 2>/dev/null
insmod /system/lib/modules/xt_recent.ko 2>/dev/null
insmod /system/lib/modules/xt_string.ko 2>/dev/null
insmod /system/lib/modules/xt_owner.ko 2>/dev/null
insmod /system/lib/modules/xt_addrtype.ko 2>/dev/null
insmod /system/lib/modules/xt_comment.ko 2>/dev/null
insmod /system/lib/modules/xt_TCPMSS.ko 2>/dev/null
insmod /system/lib/modules/xt_LOG.ko 2>/dev/null
insmod /system/lib/modules/xt_REJECT.ko 2>/dev/null
insmod /system/lib/modules/xt_MASQUERADE.ko 2>/dev/null
insmod /system/lib/modules/xt_NAT.ko 2>/dev/null
insmod /system/lib/modules/xt_REDIRECT.ko 2>/dev/null
insmod /system/lib/modules/xt_TEE.ko 2>/dev/null
insmod /system/lib/modules/xt_CT.ko 2>/dev/null
insmod /system/lib/modules/xt_CLASSIFY.ko 2>/dev/null
insmod /system/lib/modules/xt_DSCP.ko 2>/dev/null
insmod /system/lib/modules/xt_HL.ko 2>/dev/null
insmod /system/lib/modules/xt_IDLETIMER.ko 2>/dev/null
insmod /system/lib/modules/xt_LED.ko 2>/dev/null
insmod /system/lib/modules/xt_length.ko 2>/dev/null
insmod /system/lib/modules/xt_mac.ko 2>/dev/null
insmod /system/lib/modules/xt_mark.ko 2>/dev/null
insmod /system/lib/modules/xt_pkttype.ko 2>/dev/null
insmod /system/lib/modules/xt_physdev.ko 2>/dev/null
insmod /system/lib/modules/xt_quota.ko 2>/dev/null
insmod /system/lib/modules/xt_rateest.ko 2>/dev/null
insmod /system/lib/modules/xt_statistic.ko 2>/dev/null
insmod /system/lib/modules/xt_tcpmss.ko 2>/dev/null
insmod /system/lib/modules/xt_time.ko 2>/dev/null
insmod /system/lib/modules/xt_u32.ko 2>/dev/null
insmod /system/lib/modules/nf_conntrack.ko 2>/dev/null
insmod /system/lib/modules/nf_conntrack_ipv4.ko 2>/dev/null
insmod /system/lib/modules/nf_conntrack_ipv6.ko 2>/dev/null
insmod /system/lib/modules/nf_nat.ko 2>/dev/null
insmod /system/lib/modules/nf_nat_ipv4.ko 2>/dev/null
insmod /system/lib/modules/nf_nat_ipv6.ko 2>/dev/null
insmod /system/lib/modules/nf_nat_ftp.ko 2>/dev/null
insmod /system/lib/modules/nf_nat_tftp.ko 2>/dev/null
insmod /system/lib/modules/nf_nat_irc.ko 2>/dev/null
insmod /system/lib/modules/nf_nat_sip.ko 2>/dev/null
insmod /system/lib/modules/nf_nat_pptp.ko 2>/dev/null
insmod /system/lib/modules/nf_nat_proto_gre.ko 2>/dev/null
insmod /system/lib/modules/nf_nat_tcp.ko 2>/dev/null
insmod /system/lib/modules/nf_nat_udp.ko 2>/dev/null
insmod /system/lib/modules/nf_log_common.ko 2>/dev/null
insmod /system/lib/modules/nf_log_ipv4.ko 2>/dev/null
insmod /system/lib/modules/nf_log_ipv6.ko 2>/dev/null
insmod /system/lib/modules/nf_defrag_ipv4.ko 2>/dev/null
insmod /system/lib/modules/nf_defrag_ipv6.ko 2>/dev/null
insmod /system/lib/modules/nf_conntrack_netbios_ns.ko 2>/dev/null
insmod /system/lib/modules/nf_conntrack_ftp.ko 2>/dev/null
insmod /system/lib/modules/nf_conntrack_tftp.ko 2>/dev/null
insmod /system/lib/modules/nf_conntrack_irc.ko 2>/dev/null
insmod /system/lib/modules/nf_conntrack_sip.ko 2>/dev/null
insmod /system/lib/modules/nf_conntrack_pptp.ko 2>/dev/null
insmod /system/lib/modules/nf_conntrack_proto_gre.ko 2>/dev/null
insmod /system/lib/modules/nf_conntrack_broadcast.ko 2>/dev/null
insmod /system/lib/modules/nf_conntrack_tcp.ko 2>/dev/null
insmod /system/lib/modules/nf_conntrack_udp.ko 2>/dev/null
insmod /system/lib/modules/iptable_raw.ko 2>/dev/null
insmod /system/lib/modules/iptable_mangle.ko 2>/dev/null
insmod /system/lib/modules/iptable_nat.ko 2>/dev/null
insmod /system/lib/modules/iptable_filter.ko 2>/dev/null
insmod /system/lib/modules/ip6table_raw.ko 2>/dev/null
insmod /system/lib/modules/ip6table_mangle.ko 2>/dev/null
insmod /system/lib/modules/ip6table_filter.ko 2>/dev/null

# Initialize iptables
echo "Initializing iptables..."
# Flush all existing rules
iptables -F
iptables -X
iptables -Z
ip6tables -F
ip6tables -X
ip6tables -Z

# Set default policies
echo "Setting default policies..."
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT ACCEPT

# Allow loopback traffic
echo "Allowing loopback traffic..."
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT

# Allow established connections
echo "Allowing established connections..."
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
ip6tables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow necessary services
echo "Allowing necessary services..."
# Allow DNS
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
ip6tables -A OUTPUT -p udp --dport 53 -j ACCEPT
ip6tables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Allow HTTP/HTTPS
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
ip6tables -A OUTPUT -p tcp --dport 80 -j ACCEPT
ip6tables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# Allow NTP
iptables -A OUTPUT -p udp --dport 123 -j ACCEPT
ip6tables -A OUTPUT -p udp --dport 123 -j ACCEPT

# Allow ICMP
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT
ip6tables -A INPUT -p icmpv6 -j ACCEPT
ip6tables -A OUTPUT -p icmpv6 -j ACCEPT

# Block malicious IPs
echo "Blocking malicious IPs..."
# Block known malicious IPs
MALICIOUS_IPS=(\n    "1.1.1.1"\n    "8.8.8.8"\n    "8.8.4.4"\n    "1.0.0.1"\n    "9.9.9.9"\n    "149.112.112.112"\n    "208.67.222.222"\n    "208.67.220.220"\n)

for IP in "${MALICIOUS_IPS[@]}"; do
    iptables -A INPUT -s "$IP" -j DROP
    iptables -A OUTPUT -d "$IP" -j DROP
    ip6tables -A INPUT -s "$IP" -j DROP
    ip6tables -A OUTPUT -d "$IP" -j DROP
done

# Block malicious domains
echo "Blocking malicious domains..."
# Block known malicious domains
MALICIOUS_DOMAINS=(\n    "analytics.google.com"\n    "ads.google.com"\n    "doubleclick.net"\n    "googleadservices.com"\n    "adsense.google.com"\n    "adwords.google.com"\n    "google-analytics.com"\n    "googletagmanager.com"\n    "googlesyndication.com"\n    "googleads.g.doubleclick.net"\n    "pagead2.googlesyndication.com"\n    "stats.g.doubleclick.net"\n    "www.google-analytics.com"\n    "ssl.google-analytics.com"\n    "analytics.twitter.com"\n    "ads.twitter.com"\n    "t.co"\n    "api.twitter.com"\n    "platform.twitter.com"\n    "syndication.twitter.com"\n    "connect.facebook.net"\n    "facebook.com"\n    "www.facebook.com"\n    "fbcdn.net"\n    "www.fbcdn.net"\n    "static.xx.fbcdn.net"\n    "scontent.xx.fbcdn.net"\n    "graph.facebook.com"\n    "api.facebook.com"\n    "login.facebook.com"\n    "www.login.facebook.com"\n    "m.facebook.com"\n    "www.m.facebook.com"\n    "l.facebook.com"\n    "edge-mqtt.facebook.com"\n    "star.c10r.facebook.com"\n    "www.instagram.com"\n    "instagram.com"\n    "api.instagram.com"\n    "i.instagram.com"\n    "scontent.cdninstagram.com"\n    "static.cdninstagram.com"\n    "graph.instagram.com"\n    "www.snapchat.com"\n    "snapchat.com"\n    "api.snapchat.com"\n    "stories.snapchat.com"\n    "ads.snapchat.com"\n    "analytics.snapchat.com"\n    "www.linkedin.com"\n    "linkedin.com"\n    "api.linkedin.com"\n    "analytics.linkedin.com"\n    "ads.linkedin.com"\n    "www.pinterest.com"\n    "pinterest.com"\n    "api.pinterest.com"\n    "analytics.pinterest.com"\n    "ads.pinterest.com"\n    "www.reddit.com"\n    "reddit.com"\n    "api.reddit.com"\n    "analytics.reddit.com"\n    "ads.reddit.com"\n    "www.tiktok.com"\n    "tiktok.com"\n    "api.tiktok.com"\n    "analytics.tiktok.com"\n    "ads.tiktok.com"\n    "www.twitch.tv"\n    "twitch.tv"\n    "api.twitch.tv"\n    "analytics.twitch.tv"\n    "ads.twitch.tv"\n    "www.youtube.com"\n    "youtube.com"\n    "api.youtube.com"\n    "analytics.youtube.com"\n    "ads.youtube.com"\n)

# Create ipset for malicious domains
ipset create malicious_domains hash:ip

# Resolve and block malicious domains
for DOMAIN in "${MALICIOUS_DOMAINS[@]}"; do
    IPS=$(nslookup "$DOMAIN" | grep -E '^Address: ' | awk '{print $2}')
    for IP in $IPS; do
        ipset add malicious_domains "$IP"
    done
done

# Block traffic to malicious domains
iptables -A OUTPUT -m set --match-set malicious_domains dst -j DROP
ip6tables -A OUTPUT -m set --match-set malicious_domains dst -j DROP

# Control app network access
echo "Controlling app network access..."
# Block network access for specific apps
BLOCKED_APPS=(\n    "com.google.android.gms"\n    "com.google.android.gsf"\n    "com.google.android.googlequicksearchbox"\n    "com.google.android.apps.tachyon"\n    "com.facebook.katana"\n    "com.instagram.android"\n    "com.snapchat.android"\n    "com.twitter.android"\n    "com.linkedin.android"\n    "com.pinterest"\n    "com.reddit.frontpage"\n    "com.ss.android.ugc.aweme"\n    "com.twitch.android.app"\n    "com.google.android.youtube"\n)

# Create ipset for blocked apps
ipset create blocked_apps hash:ip

# Block network access for blocked apps
for APP in "${BLOCKED_APPS[@]}"; do
    # Get app UID
    UID=$(pm list packages -U | grep "$APP" | cut -d= -f2)
    if [ -n "$UID" ]; then
        iptables -A OUTPUT -m owner --uid-owner "$UID" -j DROP
    fi
done

# Log dropped packets
echo "Enabling packet logging..."
iptables -A INPUT -j LOG --log-prefix "[FIREWALL] DROP INPUT: " --log-level 6
iptables -A FORWARD -j LOG --log-prefix "[FIREWALL] DROP FORWARD: " --log-level 6
iptables -A OUTPUT -j LOG --log-prefix "[FIREWALL] DROP OUTPUT: " --log-level 6
ip6tables -A INPUT -j LOG --log-prefix "[FIREWALL] DROP INPUT (IPv6): " --log-level 6
ip6tables -A FORWARD -j LOG --log-prefix "[FIREWALL] DROP FORWARD (IPv6): " --log-level 6
ip6tables -A OUTPUT -j LOG --log-prefix "[FIREWALL] DROP OUTPUT (IPv6): " --log-level 6

# Save iptables rules
echo "Saving iptables rules..."
iptables-save > /data/adb/magisk/iptables.rules
ip6tables-save > /data/adb/magisk/ip6tables.rules

# Create init script to restore rules on boot
echo "Creating init script..."
cat > /data/adb/service.d/firewall.sh << 'EOF'
#!/system/bin/sh
# firewall.sh - Restore iptables rules on boot

# Load iptables rules
if [ -f /data/adb/magisk/iptables.rules ]; then
    iptables-restore < /data/adb/magisk/iptables.rules
fi

if [ -f /data/adb/magisk/ip6tables.rules ]; then
    ip6tables-restore < /data/adb/magisk/ip6tables.rules
fi
EOF

chmod 755 /data/adb/service.d/firewall.sh

echo "Firewall settings applied successfully!"
