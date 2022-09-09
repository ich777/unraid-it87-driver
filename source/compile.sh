# Create necessary directories and clone repository
mkdir ${DATA_DIR}/IT87
mkdir -p /ite/lib/modules/${UNAME}/kernel/drivers/hwmon
cd ${DATA_DIR}/IT87
git clone https://github.com/frankcrawford/it87
cd ${DATA_DIR}/IT87/it87
PLUGIN_VERSION="$(git log -1 --format="%cs" | sed 's/-//g')"

# Compile module and copy it over to destination
make -j${CPU_COUNT}
cp ${DATA_DIR}/IT87/it87/it87.ko /ite/lib/modules/${UNAME}/kernel/drivers/hwmon/

# Compress module
while read -r line
do
  xz --check=crc32 --lzma2 $line
done < <(find /ite/lib/modules/${UNAME}/kernel/drivers/hwmon/ -name "*.ko")

# Download icon
cd ${DATA_DIR}
mkdir -p /ite/usr/local/emhttp/plugins/it87-driver/images
wget -O /ite/usr/local/emhttp/plugins/it87-driver/images/it87-driver.png https://raw.githubusercontent.com/ich777/docker-templates/master/ich777/images/ite.png

# Create Slackware Package
PLUGIN_NAME="it87"
BASE_DIR="/ite"
TMP_DIR="/tmp/${PLUGIN_NAME}_"$(echo $RANDOM)""
VERSION="$(date +'%Y.%m.%d')"

mkdir -p $TMP_DIR/$VERSION
cd $TMP_DIR/$VERSION
cp -R $BASE_DIR/* $TMP_DIR/$VERSION/
mkdir $TMP_DIR/$VERSION/install
tee $TMP_DIR/$VERSION/install/slack-desc <<EOF
       |-----handy-ruler------------------------------------------------------|
$PLUGIN_NAME: $PLUGIN_NAME
$PLUGIN_NAME:
$PLUGIN_NAME:
$PLUGIN_NAME: Custom $PLUGIN_NAME package for Unraid Kernel v${UNAME%%-*} by ich777
$PLUGIN_NAME: Source: https://github.com/frankcrawford/it87
$PLUGIN_NAME:
EOF
${DATA_DIR}/bzroot-extracted-$UNAME/sbin/makepkg -l n -c n $TMP_DIR/$PLUGIN_NAME-$PLUGIN_VERSION-$UNAME-1.txz
md5sum $TMP_DIR/$PLUGIN_NAME-$PLUGIN_VERSION-$UNAME-1.txz | awk '{print $1}' > $TMP_DIR/$PLUGIN_NAME-$PLUGIN_VERSION-$UNAME-1.txz.md5
