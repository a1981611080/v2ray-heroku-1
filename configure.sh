#!/bin/sh

# Download and install V2Ray
mkdir /tmp/v2ray
curl -L -H "Cache-Control: no-cache" -o /tmp/v2ray/v2ray.zip https://github.com/v2ray/v2ray-core/releases/latest/download/v2ray-linux-64.zip
unzip /tmp/v2ray/v2ray.zip -d /tmp/v2ray
install -m 755 /tmp/v2ray/v2ray /usr/local/bin/v2ray
install -m 755 /tmp/v2ray/v2ctl /usr/local/bin/v2ctl

# Remove temporary directory
rm -rf /tmp/v2ray

# V2Ray new configuration
install -d /usr/local/etc/v2ray
cat << EOF > /usr/local/etc/v2ray/config.json
{
  "log": {
      "access": "/var/log/v2ray/access.log",
      "error": "/var/log/v2ray/error.log",
      "loglevel": "warning"
  },
  "inbound": {
      "port": 80,
      "protocol": "vmess",
      "settings": {
          "clients": [
              {
                  "id": "a641f8a8-470b-8805-903d-fe5840481cb5",
                  "level": 1,
                  "email": "http@4xx.me",
                  "alterId": 64
              }
          ]
      },
      "streamSettings": {
        "network": "tcp",
        "httpSettings": { 
            "path": "/http"
        },
        "tcpSettings": {
            "header": { 
              "type": "http",
              "response": {
                "version": "1.1",
                "status": "200",
                "reason": "OK",
                "headers": {
                  "Content-Type": ["application/octet-stream", "application/x-msdownload", "text/html", "application/x-shockwave-flash"],
                  "Transfer-Encoding": ["chunked"],
                  "Connection": ["keep-alive"],
                  "Pragma": "no-cache"
                }
              }
            }
        }
      }
  },
  "outbound": {
      "protocol": "freedom",
      "settings": {}
  },
  "inboundDetour": [
      {
          "port": 10000,
          "listen":"127.0.0.1",
          "protocol": "vmess",
          "settings": {
              "clients": [
                  {
                      "id": "ed827005-d9cc-dfe2-161a-2e0b0f0b077a",
                      "level": 1,
                      "email": "https@4xx.me",
                      "alterId": 64
                  }
              ]
          },
          "streamSettings": {
                "network": "ws",
                "wsSettings": {
                    "path": "/https"
                }
            }
      }
  ],
  "outboundDetour": [
      {
          "protocol": "blackhole",
          "settings": {},
          "tag": "blocked"
      }
  ],
  "routing": {
      "strategy": "rules",
      "settings": {
          "rules": [
              {
                  "type": "field",
                  "ip": [
                      "0.0.0.0/8",
                      "10.0.0.0/8",
                      "100.64.0.0/10",
                      "127.0.0.0/8",
                      "169.254.0.0/16",
                      "172.16.0.0/12",
                      "192.0.0.0/24",
                      "192.0.2.0/24",
                      "192.168.0.0/16",
                      "198.18.0.0/15",
                      "198.51.100.0/24",
                      "203.0.113.0/24",
                      "::1/128",
                      "fc00::/7",
                      "fe80::/10"
                  ],
                  "outboundTag": "blocked"
              }
          ]
      }
  }
}
EOF

# Run V2Ray
/usr/local/bin/v2ray -config /usr/local/etc/v2ray/config.json
