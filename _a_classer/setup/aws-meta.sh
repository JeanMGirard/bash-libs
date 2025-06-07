
BASE_URL="http://169.254.169.254/latest"
TOKEN=`curl -X PUT "$BASE_URL/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
TOKEN_H="X-aws-ec2-metadata-token: $TOKEN"

export PUBLIC_IPV4="$(curl -H "$TOKEN_H" -s $BASE_URL/meta-data/public-ipv4)"
export LOCAL_IPV4="$(curl -H "$TOKEN_H" -s $BASE_URL/meta-data/local-ipv4)"
export LOCAL_HOSTNAME="$(curl -H "$TOKEN_H" -s $BASE_URL/meta-data/local-hostname)"
export PUBLIC_HOSTNAME="$(curl -H "$TOKEN_H" -s $BASE_URL/meta-data/public-hostname)"
export LAUNCH_INDEX="$(curl -H "$TOKEN_H" -s $BASE_URL/meta-data/ami-launch-index)"
export TAGS="$(curl -H "$TOKEN_H" -s $BASE_URL/meta-data/tags/instance)"

#sudo hostnamectl set-hostname $LOCAL_HOSTNAME
#echo "127.0.0.1   $PUBLIC_HOSTNAME $LOCAL_HOSTNAME " | sudo tee -a  /etc/hosts
#
#printf "
#export PUBLIC_IPV4='${PUBLIC_IPV4}'
#export LOCAL_IPV4='${LOCAL_IPV4}'
#export LOCAL_HOSTNAME='${LOCAL_HOSTNAME}'
#export PUBLIC_HOSTNAME='${PUBLIC_HOSTNAME}'
#export LAUNCH_INDEX=${LAUNCH_INDEX}
#" | tee -a $PROFILE

#sudo hostnamectl set-hostname $(curl http://169.254.169.254/latest/meta-data/hostname)
#sudo hostnamectl set-hostname $(curl -s http://169.254.169.254/latest/meta-data/local-hostname)

# curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/
#ami-launch-index
#ami-manifest-path
#block-device-mapping/
#events/
#hostname
#iam/
#instance-action
#instance-id
#instance-life-cycle
#instance-type
#local-hostname
#local-ipv4
#mac
#metrics/
#network/
#placement/
#profile
#public-hostname
#public-ipv4
#public-keys/
#reservation-id
#security-groups
#services/

#
# curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/dynamic/
#rsa2048
#pkcs7
#document
#signature
#dsa2048



