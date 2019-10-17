#!/bin/bash
########################################################################################################################
# @params phone_adb_url 手机网络调试地址
# @params dingding_package 钉钉的主页包名（如何获取查看下面说明）
# Tip：
#       手机打开钉钉，在adb模式下输入"dumpsys window windows | grep "Current"
#       输出为 mCurrentFocus=Window{424168a8 u0 com.alibaba.android.rimet/com.alibaba.android.rimet.biz.LaunchHomeActivity
#       com.alibaba.android.rimet/com.alibaba.android.rimet.biz.LaunchHomeActivity 即钉钉的包/主页
########################################################################################################################
phone_local="yes"
phone_adb_ip="192.168.10.120"
phone_adb_port="5555"
phone_model="A0001"
dingding_package="om.alibaba.android.rimet/com.alibaba.android.rimet.biz.LaunchHomeActivity"

<<COMMENT
    $1 => 提示语
    $2 => 时间（秒）
COMMENT
wait_tip(){
    echo -n $1
    i=$2
    while(($i>1))
    do
        echo -n "."
        sleep 1s
        let i--
    done
    echo ""
}

phone_operating(){
    adb shell am force-stop com.alibaba.android.rimet
    wait_tip "Stop dingtalk application" 2

    adb shell input keyevent 26              
    adb shell am start -n com.alibaba.android.rimet/com.alibaba.android.rimet.biz.LaunchHomeActivity

    wait_tip "Start dingtalk application" 9

    # 点击打卡界面，进入打卡，滑动界面，再点击打卡
    adb shell input tap 540 1850
    wait_tip "Waiting dingtalk loading check-in view" 9
    i=0
    while(($i > 3))
    do
        adb shell input swipe 500 300 500 1600              # 循环多次保证滑到最顶
        let i++
    done
    adb shell input swipe 500 1650 500 1000
    adb shell input swipe 500 1650 500 1000
    adb shell input tap 140 450
    wait_tip "Waiting dingtalk loading check-in view" 9

    echo -n "Start check-in"
    adb shell input tap 540 1150
    adb shell input tap 205 1150
    wait_tip "Waiting check-in success" 5
    adb shell input tap 850 1060

    echo -n "Congratulations!the script execute finish!!" 1
}

if [[ $phone_local == "yes" ]];then
    phone_operating
    exit 0
fi

# Check phone in this network
ping -c 1 -w 5 $phone_adb_ip
if [[ $? != 0 ]];then
echo "sorry,your phone seem not in this network"
exit 1
fi
echo "your phone is connect,waiting check adb connect"

# Check adb connecting phone status
adb connect $phone_adb_ip:$phone_adb_port
i=0
adb_connect_result=`adb shell getprop ro.product.model`
if [[ $adb_connect_result =~ $phone_model ]];then
    phone_operating
    exit 0
fi
adb kill-server
adb connect $phone_adb_ip:$phone_adb_port
adb_connect_result=`adb shell getprop ro.product.model`
if [[ $adb_connect_result =~ $phone_model ]];then
    phone_operating
    exit 0
fi