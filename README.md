![][demo]

### WatchOS 3.0 Complication of Real-time Air Quality for Major Chinese Cities 苹果表盘实时刷新北上广沈蓉空气质量
* Real-time PM 2.5 readings for major Chinese cities right on your clock face.
* All five major Chinese cities included: Shanghai, Beijing, Guangzhou, Shenyang and Chengdu.
* Closely tracks the latest data with a maximum delay of 30 minutes.
* A clean and consice complication widget that fits perfectly on your every WatchOS 3.0 clock face.
* Written with and compiled against the latest Swift 3.0 SDK.

[]()

* 在你的苹果手表表盘上追踪最新空气污染数据。
* 支持城市: 上海、北京、广州、沈阳和成都。
* 实时后台刷新，最大延迟小于30分钟。
* 精美 complication 视图，适配 WatchOS 3.0 所有表盘。
* 使用最新 Swift 3.0 编写。

### Don't Take Clean Air for Granted 空气质量与健康息息相关

![][beijing_aqi]

### Where the Data Come from? 数据源
* [http://shanghai.usembassy-china.org.cn/airmonitor.html](http://shanghai.usembassy-china.org.cn/airmonitor.html)
* [http://beijing.usembassy-china.org.cn/070109air.html](http://beijing.usembassy-china.org.cn/070109air.html)
* [http://guangzhou.usembassy-china.org.cn/guangzhou-air-quality-monitor.html](http://guangzhou.usembassy-china.org.cn/guangzhou-air-quality-monitor.html)
* [http://www.stateair.net/web/post/1/5.html](http://www.stateair.net/web/post/1/5.html)
* [http://chengdu.usembassy-china.org.cn/air-quality-monitor4.html](http://chengdu.usembassy-china.org.cn/air-quality-monitor4.html)

### How to Install 如何安装
1. Make sure you have an iPhone paired with an Apple Watch.
2. Connect your iPhone to your Mac computer.
3. Clone the project.
4. Run the complication target on your iPhone.
5. Let Xcode help you if there's any code signing error.
6. When you see logs appearing in the Xcode console, the installation is done. Hit the stop button.

[]()

1. 准备好 iPhone 和与之匹配的苹果手表
2. 将 iPhone 连接到电脑上
3. 将源代码克隆到本地
4. 运行 complication target
5. 如果出现代码签名错误，让 Xcode 尝试自动解决。
6. 当 Xcode 控制台开始打印日志时，说明安装已经完成。点击停止按钮。


### How to Set-up the Complication 如何设置表盘 Complication
1. Go to your watch. Force touch to customize. Find the complication named *PM2.5*.
2. If the reading is not ready yet, you will see *Press to Refresh* (or *??* if the comllication style you choose is a smaller one.). 
3. Press the complication to see the watch app.
4. In the watch app, press the *City* button to select your city.
5. Also in the watch app, press the *Refresh* button to force-start the initial refresh. 
6. When the watch app is done refreshing, you will find meaningful data displayed right above the refresh and city buttons.
7. When the refresh is done, hit the digital crown to go back to the clock face.

[]()

1. 用力按压表盘，进入自定义表盘模式，找到名字叫 *PM2.5* 的 Complication。
2. 如果实时刷新数据尚未就绪，你将会看到 *Press to Refresh* 字样（或者是 "??" 字样，如果你选择的 Complication 样式比较小）。
3. 点击 Complication，进入对应的 Watch App。
4. 在 Watch App 中，点击 *City* 按钮选择城市。
5. 仍然在 Watch App 中，点击 *Refresh* 按钮触发第一次强制刷新。
6. 如果刷新成功，你会在按钮上方看到最新的空气污染数据。
7. 刷新成功以后，按压电子旋钮回到表盘。

### Auto-refresh is Implemented Using WKRefreshBackgroundTask 后台自动刷新使用 WKRefreshBackgroundTask 实现

### Enable the Hidden Debug Mode 开启隐藏的 Debug 模式
* If you want to dive in and play around, go to the *CommonUtil.swift*, set *DEBUG_LOCAL_NOTIFICATION* to *true*. Delete and reinstall the app, debug information will start popping up from time to time as local notifications.
* 如果你想深入了解代码每时每刻的工作状况，去 *CommonUtil.swift* 里面，将 *DEBUG_LOCAL_NOTIFICATION* 设为 *true* 。删掉然后重装 app。代码的工作情况将会以本地通知的形式呈现在你眼前。



[beijing_aqi]: https://raw.githubusercontent.com/diwu/ui-markdown-store/master/aqi_3.jpg
[demo]: https://github.com/diwu/ui-markdown-store/blob/master/watch_demo_4.jpg?raw=true
[source]: http://www.stateair.net/web/post/1/4.html