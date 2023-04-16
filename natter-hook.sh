protocol=$1
inner_ip=$2
inner_port=$3
outter_ip=$4
outter_port=$5

echo "[Script] - Upload to server: ${protocol}: ${inner_ip}:${inner_port} -> ${outter_ip}:${outter_port}"

# Write your upload script below...

# 消息服务器
gotify_url="http://gotify"
gotify_token="123"

# 配置qBittorrent，注意是http还是https
# 加空格。。。
if [ $protocol = "tcp" ]; then
    case $inner_port in
    "6500")
        qb_web_url="http://pt"
        server="pt"
        qb_username="admin"
        qb_password="123"
        ;;
    "6600")
        # bt
        qb_web_url="http://bt"
        server="bt"
        qb_username="admin"
        qb_password="123"
        ;;
    esac
else
    echo ""
fi
echo "所使用的传输协议:${protocol}"
echo "为服务器: ${server} 打洞"

# 这里搭配自动修改qbittorrent的端口转发的Hook，qBittorrent传输需要内外端口一致
target_port=$outter_port

echo "更新服务器: ${server} 监听端口到 $outter_port..."

qb_cookie=$(curl --insecure -s -i --header "Referer: $qb_web_url" --data "username=$qb_username&password=$qb_password" $qb_web_url/api/v2/auth/login | grep -i set-cookie | cut -c13-48)
curl --insecure -X POST -b "$qb_cookie" -d 'json={"listen_port":"'$outter_port'"}' "$qb_web_url/api/v2/app/setPreferences"

echo "Update qBittorrent listen port successfully"

# 发送消息给消息服务器
echo "发送消息给gotify"
gotify_priority="5"
message_title="端口更新: ${server}"
message_content="服务器: ${qb_web_url}
wan端口: ${inner_port}
监听端口: ${target_port}"

curl "${gotify_url}/message?token=${gotify_token}" -F "title=${message_title}" -F "message=${message_content}" -F "priority=${gotify_priority}"
# curl -s -S --data '{"message": "'"${message_content}"'", "title": "'"${message_title}"'", "priority":'"${gotify_priority}"', "extras": {"client::display": {"contentType": "text/markdown"}}}' -H 'Content-Type: application/json' "${gotify_url}/message?token=${gotify_token}"
