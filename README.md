# 说明
一个基于Bash/Adb制作的简易自动打卡脚本，结合Python Flask的web服务实现http请求自动打卡，请自行根据需要扩展/修改脚本

改脚本在1080P分辨率下测试通过，如是其他分辨率，**涉及到 点击/滑动操作的需要自行更改脚本坐标**

本项目搭配内网穿透使用可以实现手机远程访问端口既可自动签到

# 条件要求
- 一台能装钉钉的Android手机（手机版本不能太低，低于4.2adb缺少一些必要功能）
- 一台支持Adb的设备
- 可选
    1. Wifi - 用于网络调试，去掉usb线的困扰
    2. Root - 用于开机自动加载网络调试

> 本文基于远程网络调试，如果你没有wifi，需要手动更改提供的脚本（删掉adb网络连接设备部分即可）

# 准备
**准备1.usb调试模式**

手机需要开启开发者模式，大部分Android手机只需要在**关于手机**里面点击内核版本5次即可，开启开发者选项之后进入开发者选项，并勾选**usb调试模式**

**准备2.PC安装adb驱动**

Linux大部分发行版自带adb驱动，Windows需要到Google下载Adb安装，[Windows Adb下载地址](https://adb.clockworkmod.com/)

安装成功后，手机连接PC，在命令行界面下尝试输入 **adb devices**，如果能看到你的设备说明安装成功

**准备3.网络调试（可选）**

手机如果需要网络调试，必须得有Wifi这个就不说了，用usb连接手机之后，使用"adb shell tcpip 5555"可以打开手机adb网络调试模式，缺点是一旦重启手机网络调试模式就失效了。

如果想要重启仍然保持改效果，则需要使用**RE文件管理器/ES文件管理器**之类的修改/system/build.prop文件，并在文件最后增加
```
adb.service.tcp.port=5555 # 端口可自定义，需要Root权限
```

# adb操作
掌握下面几个adb操作，就可以调整本文提供的脚本了
```
# 杀死adb连接
adb kill-server
# 连接网络调试手机
adb connect ip:port
# 查看当前连接的手机列表
adb devices
# 启动/停止app
adb shell am start -n package/Activity
adb shell am force-stop package
# 获取app启动的package/Activity名称（需要启动app后执行这句话）
"dumpsys window windows | grep "Current"
# 按电源键
adb shell input keyevent 26  
# 点击/拖动屏幕                                                                                                                                          adb shell input tap 540 1850
adb shell input swipe 500 700 500 50
```

# 直接使用
1. 单独执行**check-in.sh**脚本，根据具体环境设备要求自行更改脚本，直到测试脚本可以正常打印，关于ADB操作可看上面介绍
2. 执行成功后后台运行 **python app.py**，访问http://127.0.0.1:30000，脚本既可自动执行，执行结束http请求结束并返回执行过程
3. 可以设置为定时执行脚本访问http端口或选择开放端口远程访问端口（默认开放）