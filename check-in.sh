#!/bin/bash
########################################################################################################################
# @params phone_adb_url 手机网络调试地址
# @params dingding_package 钉钉的主页包名（如何获取查看下面说明）
# Tip：
#       手机打开钉钉，在adb模式下输入"dumpsys window windows | grep "Current"
#       输出为 mCurrentFocus=Window{424168a8 u0 com.alibaba.android.rimet/com.alibaba.android.rimet.biz.LaunchHomeActivity
#       com.alibaba.android.rimet/com.alibaba.android.rimet.biz.LaunchHomeActivity 即钉钉的包/主页
########################################################################################################################

phone_adb_url="192.168.10.120:5555"
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

# 连接手机
adb kill-server
adb connect $phone_adb_url
wait_tip "连接手机" 5

echo "手机adb连接列表"
adb devices
devices=`adb devices`
if [[ $devices =~ $phone_adb_url ]]
then
    echo "连接成功！"
else
    echo "错误：没有连接到设备"
    wait_tip "自动打卡失败，程序正在退出" 3
    exit 1
fi

# 初始化状态
adb shell am force-stop com.alibaba.android.rimet
wait_tip "初始化状态" 5

adb shell input keyevent 26                                                                                                                                                             
adb shell input swipe 500 700 500 50
wait_tip "解锁手机" 5

# 根据查找到的钉钉包名称启动钉钉
adb shell am start -n com.alibaba.android.rimet/com.alibaba.android.rimet.biz.LaunchHomeActivity
wait_tip "启动钉钉" 5
wait_tip "等待钉钉加载成功" 20

# 点击打卡界面，进入打卡，滑动界面，再点击打卡
adb shell input tap 540 1850
wait_tip "加载应用界面" 20
i=0
while(($i > 3))
do
    adb shell input swipe 500 300 500 1600              # 循环多次保证滑到最顶
    let i++
done
adb shell input swipe 500 1650 500 1000
adb shell input swipe 500 1650 500 1000
wait_tip "定位打卡入口" 5
adb shell input tap 140 450
wait_tip "进入打卡界面" 20

y=700
punch=0
echo -n "开始打卡"
while(($punch < 7))
do
    adb shell input tap 550 $y
    let y=y+100
    let punch++
    echo -n "."
    sleep 1s
done

# 关闭钉钉
adb shell am force-stop com.alibaba.android.rimet
wait_tip "打卡结束，正在关闭钉钉，拜拜！" 3
