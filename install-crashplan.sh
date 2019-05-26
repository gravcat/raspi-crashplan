#!/bin/bash
# This is a simple script that installs CrashPlan (from https://www.code42.com)
# on a Raspberry Pi.
# Written/Tested on Rasbperry Pi 3 Model B, running Raspbian Jessie
#
# Summary of steps:
# - Download and unpack CrashPlan Linux tarball
# - Modify install.sh to use Raspbian's oracle java instead of downloading own
# - Run the installer
# - Remove the x86 .so files from install directory
# - Download prebuilt libjtux.so (from Jon Rogers blog)
# - Install packages: libjna-java libswt-gtk-4-java libswt-cairo-gtk-4-jni
# - Replace CrashPlan's swt.jar with a link to the one from libswt-gtk-4-java

set -e

# Change this for new versions, but this is the version i've tested
CRASHPLAN_ARCHIVE_NAME=CrashPlanSmb_6.9.4_1525200006694_502_Linux.tgz
CRASHPLAN_DOWNLOAD_URL=https://www.crashplanpro.com/client/installers/$CRASHPLAN_ARCHIVE_NAME
# Change this if you want to install somewhere else, probably should be a
# command line option
TARGET=/usr/local/crashplan

# Use /tmp for temporary files... probably should check for free space
cd /tmp
if [ ! -f $CRASHPLAN_ARCHIVE_NAME ]; then
  echo "downloading crashplan from $CRASHPLAN_DOWNLOAD_URL"
  wget $CRASHPLAN_DOWNLOAD_URL
fi

echo "unpacking $CRASHPLAN_ARCHIVE_NAME"
tar xzf $CRASHPLAN_ARCHIVE_NAME

sudo apt-get install -y openjdk-8-jdk-headless

cd crashplan-install
JAVA=`ls /usr/lib/jvm/*1.8.0*jdk*/bin/java`
echo "existing java is at $JAVA"
echo "removing JRE download from install.sh"
mv install.sh install.sh.orig
sed "s|^JAVACOMMON=\"DOWNLOAD\"|JAVACOMMON=\"$JAVA\"|" install.sh.orig > install.sh
chmod 700 install.sh

echo "running install.sh"
sudo ./install.sh $TARGET

echo "removing these x86 files from crashplan installation"
ls -l $TARGET/*.so
sudo /bin/rm $TARGET/*.so

echo "downloading Jon Rogers libjtux.so - see http://www.jonrogers.co.uk/2012/05/crashplan-on-the-raspberry-pi/"
cd /tmp
wget "http://www.jonrogers.co.uk/wp-content/uploads/2012/05/libjtux.so"
sudo mv libjtux.so $TARGET


echo "installing libjna-java, libgconf-2-4"
sudo apt-get install libjna-java libswt-gtk-4-java libswt-cairo-gtk-4-jni libgconf-2-4 -y

SWT=`ls /usr/lib/java/swt*`
echo "replacing $TARGET/lib/swt.jar with link to $SWT"
sudo mv $TARGET/lib/swt.jar $TARGET/lib/swt.tar.orig
sudo ln -s $SWT $TARGET/lib/swt.jar
