protocol=$1
inner_ip=$2
inner_port=$3
outter_ip=$4
outter_port=$5

echo "[Script] - Upload to server: ${protocol}: ${inner_ip}:${inner_port} -> ${outter_ip}:${outter_port}"

# Write your upload script below...
# 配置qBittorrent，注意是http还是https
# 加空格。。。
if [ $protocol = "tcp" ]; then
    echo "传输协议：tcp"
    case $inner_port in
    "6500")
        qb_web_url="http://pt"
        qb_username="admin"
        qb_password="admin"
        echo "server:pt"
        ;;
    "6600")
        # bt
        qb_web_url="http://bt"
        qb_username="admin"
        qb_password="admin"
        echo "server:bt"
        ;;
    esac
else
    echo "协议：udp"
fi
# 这里搭配自动修改端口转发的Hook，qBittorrent传输需要内外端口一致
target_port=$outter_port

echo "Update qBittorrent listen port to $outter_port..."

qb_cookie=$(curl --insecure -s -i --header "Referer: $qb_web_url" --data "username=$qb_username&password=$qb_password" $qb_web_url/api/v2/auth/login | grep -i set-cookie | cut -c13-48)
curl --insecure -X POST -b "$qb_cookie" -d 'json={"listen_port":"'$outter_port'"}' "$qb_web_url/api/v2/app/setPreferences"

echo "Update qBittorrent listen port successfully"
