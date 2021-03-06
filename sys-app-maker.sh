clear
###  Color & shortcut ###
red="\e[1;91m"
green="\e[1;92m"
blue="\e[1;95m"
white="\e[0m"
solidred="\e[1;41m"
solidgreen="\e[1;42m"
solidpink="\e[1;45m"
solidskyblue="\e[1;46m"
sred="\e[1;101m"
sgreen="\e[1;102m"
sblue="\e[1;104m"
spink="\e[1;105m"
sskyblue="\e[1;106m"
sudo="su -c"
### Checker ###
check(){
	if [ $(echo $?) -eq 0 ]; then
		echo -e "${blue}$1 --> ${green}OK${white}"
		flag=1
	else
		echo -e "${blue}$1 --> ${red}ERROR${white}"
		flag=0
	fi
}
echo -e "${sblue} REM MAGISK MODULE SYSTEMIZER  ${white}\n"
sleep 3
### package ###
zip -v > /dev/null 2>&1
check Zip_Install_Check
[[ $flag == 0 ]] && yes | pkg install zip
unzip -v > /dev/null 2>&1
check Unzip_Install_Check
[[ $flag == 0 ]] && yes | pkg install unzip
### Setting Permission ###
$sudo mount -o remount,rw /
check Mounting_System
echo -ne "\n\n\e[1;101m ---Options--- ${white}\n\n\e[1;32m1. /system/priv-app\n\e[1;34m2. /system/product/app/\n\e[1;36m3. /system/app\n\n${white}${solidred}Choose option:${white} "
read option
if [ $option -eq 1 ]; then
        fol="/sdcard/SysMake/system/priv-app"
elif [ $option -eq 2 ]; then
        fol="/sdcard/SysMake/system/product/app/"
elif [ $option -eq 3 ]; then
        fol="/sdcard/SysMake/system/app/"
else
        echo -e "${red}Wrong Choice${white}"
fi
mkdir -p $fol
### APP checking ###
read -p $'\e[1;92mEnter App Name or package name (eg. com.whatsapp) / (eg. whatsapp): \e[0m' appName
### if app folder not present
if [ ! -e "/sdcard/$appName" ]; then
        echo -e "${red}App Folder Not Found in '/sdcard'${white}"
        read -p $'\n\e[1;95mIs the app already installed as User APP (y/n): ' choice
        ### Copying apk to /sdcard/app/app.apk
        if [ "$choice" == "y" ]; then
                $sudo mkdir -p /sdcard/$appName
                $sudo pm list packages -f | grep -i "$appName" | grep "/data/app" | sed -e 's/.*package:\(.*\)=\(.*\)/\1/' | xargs -I '{}' cp {} /sdcard/$appName/$appName.apk
                check Exporting_APK_to_sdcard
        else
                exit 1
        fi
fi
### if app folder is present
        mv /sdcard/$appName/*.apk /sdcard/$appName/$appName.apk > /dev/null 2>&1
	cp -R /sdcard/$appName $fol
	rm -rf /sdcard/$appName
checkLoop="y"
app_loop(){

### APP checking ###
read -p $'\e[1;92mEnter App Name or package name (eg. com.whatsapp) / (eg. whatsapp): \e[0m' appName
### if app folder not present
if [ ! -e "/sdcard/$appName" ]; then 
	echo -e "${red}App Folder Not Found in '/sdcard'${white}"
	read -p $'\n\e[1;95mIs the app already installed as User APP (y/n): ' choice
	### Copying apk to /sdcard/app/app.apk
	if [ "$choice" == "y" ]; then  
		$sudo mkdir -p /sdcard/$appName
		$sudo pm list packages -f | grep -i "$appName" | grep "/data/app" | sed -e 's/.*package:\(.*\)=\(.*\)/\1/' | xargs -I '{}' cp {} /sdcard/$appName/$appName.apk
		check Exporting_APK_to_sdcard
	else
		exit 1
	fi
fi
### if app folder is present
	mv /sdcard/$appName/*.apk /sdcard/$appName/$appName.apk > /dev/null 2>&1
	cp -R /sdcard/$appName $fol
	rm -rf /sdcard/$appName

}
	while [[ "$checkLoop" == "y" ]]
	do
	read -p $'\e[1;91m\nDo you want to add more app (y/n): ' checkLoop
	echo ""
	[[ "$checkLoop" == "y" ]] || [[ "$checkLoop" == "Y" ]] && { app_loop; }
	done
	mkdir -p /sdcard/SysMake
	cat <<- 'EOF'> /sdcard/SysMake/Install.sh
		##########################################################################################
#
# Magisk Module Installer Script
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure and implement callbacks in this file
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################
##########################################################################################
# Config Flags
##########################################################################################
# Set to true if you do *NOT* want Magisk to mount
# any files for you. Most modules would NOT want
# to set this flag to true
SKIPMOUNT=false
# Set to true if you need to load system.prop
PROPFILE=false
# Set to true if you need post-fs-data script
POSTFSDATA=false
# Set to true if you need late_start service script
LATESTARTSERVICE=false
##########################################################################################
# Replace list
##########################################################################################
# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this
# Construct your list in the following format
# This is an example
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"
# Construct your own list here
REPLACE="
"
##########################################################################################
#
# Function Callbacks
#
# The following functions will be called by the installation framework.
# You do not have the ability to modify update-binary, the only way you can customize
# installation is through implementing these functions.
#
# When running your callbacks, the installation framework will make sure the Magisk
# internal busybox path is *PREPENDED* to PATH, so all common commands shall exist.
# Also, it will make sure /data, /system, and /vendor is properly mounted.
#
##########################################################################################
##########################################################################################
#
# The installation framework will export some variables and functions.
# You should use these variables and functions for installation.
#
# ! DO NOT use any Magisk internal paths as those are NOT public API.
# ! DO NOT use other functions in util_functions.sh as they are NOT public API.
# ! Non public APIs are not guranteed to maintain compatibility between releases.
#
# Available variables:
#
# MAGISK_VER (string): the version string of current installed Magisk
# MAGISK_VER_CODE (int): the version code of current installed Magisk
# BOOTMODE (bool): true if the module is currently installing in Magisk Manager
# MODPATH (path): the path where your module files should be installed
# TMPDIR (path): a place where you can temporarily store files
# ZIPFILE (path): your module's installation zip
# ARCH (string): the architecture of the device. Value is either arm, arm64, x86, or x64
# IS64BIT (bool): true if $ARCH is either arm64 or x64
# API (int): the API level (Android version) of the device
#
# Availible functions:
#
# ui_print <msg>
#     print <msg> to console
#     Avoid using 'echo' as it will not display in custom recovery's console
#
# abort <msg>
#     print error message <msg> to console and terminate installation
#     Avoid using 'exit' as it will skip the termination cleanup steps
#
# set_perm <target> <owner> <group> <permission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     this function is a shorthand for the following commands
#       chown owner.group target
#       chmod permission target
#       chcon context target
#
# set_perm_recursive <directory> <owner> <group> <dirpermission> <filepermission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     for all files in <directory>, it will call:
#       set_perm file owner group filepermission context
#     for all directories in <directory> (including itself), it will call:
#       set_perm dir owner group dirpermission context
#
##########################################################################################
##########################################################################################
# If you need boot scripts, DO NOT use general boot scripts (post-fs-data.d/service.d)
# ONLY use module scripts as it respects the module status (remove/disable) and is
# guaranteed to maintain the same behavior in future Magisk releases.
# Enable boot scripts by setting the flags in the config section above.
##########################################################################################
# Set what you want to display when installing your module
print_modname() {
  ui_print "*******************************"
  ui_print "           REMKU                    "
  ui_print "*******************************"
}
on_install() {
  # The following is the default implementation: extract $ZIPFILE/system to $MODPATH
  # Extend/change the logic to whatever you want
  ui_print "- Extracting module files"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
  warn_if_superfluous
  mask_lib
}
# Copy/extract your module files into $MODPATH in on_install.
# Only some special files require specific permissions
# This function will be called after on_install is done
# The default permissions should be good enough for most cases
set_permissions() {
  # The following is the default rule, DO NOT remove
  set_perm_recursive $MODPATH 0 0 0755 0644
  # Here are some examples:
  # set_perm_recursive  $MODPATH/system/lib       0     0       0755      0644
  # set_perm  $MODPATH/system/bin/app_process32   0     2000    0755      u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0     2000    0755      u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0     0       0644
}
# You can add more functions to assist your custom script code
EOF

### changing ui print 
sed -i "s/REMKU/MagiskSystemAppMaker/" /sdcard/SysMake/Install.sh 

read -p $'\e[1;92m\n\n[OPTIONAL] Do you want to add module property (y/n): \e[0m' modprop
if [[ "$modprop" == "Y" ]] || [[ "$modprop" == "y" ]]; then
### input for module.prop
echo -ne "\n\n${sred}  Module.prop  ${white}${green}\n\nid = ${white}"
read id
echo -ne "${green}name = ${white}"
read name 
echo -ne "${green}version = ${white}"
read version
echo -ne "${green}versionCode = ${white}"
read versionCode
echo -ne "${green}author = ${white}"
read author
echo -ne "${green}description = ${white}"
read description
### making module.prop
cat <<- EOF> /sdcard/SysMake/module.prop
id=$id
name=$name
version=v$version 
versionCode=$versionCode
author=$author
description=$description
EOF

else
### making module.prop
cat <<- EOF> /sdcard/SysMake/module.prop
id=101
name=SystemApp
version=1
versionCode=1
author=System
description=SystemApp
EOF
fi
echo -e "\n${blue}module.prop --> ${green} Created${white}"
unzip $HOME/sys-app-maker-magisk/meta-common.zip -d /sdcard/SysMake/
cd /sdcard/SysMake/
zip -r Magisk-System-App.zip ./*
rm -rf /sdcard/SysMake/META-INF /sdcard/SysMake/common /sdcard/SysMake/Install.sh /sdcard/SysMake/system /sdcard/SysMake/module.prop
echo -e "\n\n${white}${solidred} Finished ${white}\n\n"

