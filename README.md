![][demo]

###WatchOS 2.0 Complication of Real-time Air Quality for Major Chinese Cities 苹果表盘实时刷新北上广沈蓉空气质量
* Real-time PM 2.5 readings for major Chinese cities right on your clock face.
* All five major Chinese cities included: Shanghai, Beijing, Guangzhou, Shenyang and Chengdu.
* Closely tracks the latest data with a maximum delay of 10 minutes.
* A clean and consice complication widget that fits perfectly on your every clock face.

[]()

* 在你的苹果手表表盘上追踪最新空气污染数据。
* 支持城市: 上海、北京、广州、沈阳和成都。
* 实时后台刷新，最大延迟小于10分钟。
* 精美 complication 视图，适配所有表盘。

###Don't Take Clean Air for Granted 空气质量与健康息息相关

![][beijing_aqi]

###Where the Data Come from? 数据源
* [http://shanghai.usembassy-china.org.cn/airmonitor.html](http://shanghai.usembassy-china.org.cn/airmonitor.html)
* [http://beijing.usembassy-china.org.cn/070109air.html](http://beijing.usembassy-china.org.cn/070109air.html)
* [http://guangzhou.usembassy-china.org.cn/guangzhou-air-quality-monitor.html](http://guangzhou.usembassy-china.org.cn/guangzhou-air-quality-monitor.html)
* [http://www.stateair.net/web/post/1/5.html](http://www.stateair.net/web/post/1/5.html)
* [http://chengdu.usembassy-china.org.cn/air-quality-monitor4.html](http://chengdu.usembassy-china.org.cn/air-quality-monitor4.html)

###How to Install 如何安装
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


###How to Set-up the Complication 如何设置表盘 Complication
1. Go to your watch. Force touch to customize. Find the complication named *PM2.5*.
2. If the reading is not ready yet, you will see *Press to Refresh* (or *??* if the comllication style you choose is a smaller one.). 
3. Press the complication to see the watch app.
4. In the watch app, press the *City* button to select your city.
5. Also in the watch app, press the *Refresh* button to force-start the initial refresh. 
6. When the watch app is done refreshing, you will find meaningful data displayed right above the refresh and city buttons.
7. If the refresh takes too long to finish, try kill the app and start all over. 
8. When the refresh is done, hit the digital crown to go back to the clock face. 
9. It's possible that when back to the clock face, you are still seeing the *Press to Refresh*  (or *??*) text instead of the air quality reading. If that's the case, force touch to switch to another clock face that doesn't have this complication, and then switch back. By now you should see the correct reading.

[]()

1. 用力按压表盘，进入自定义表盘模式，找到名字叫 *PM2.5* 的 Complication。
2. 如果实时刷新数据尚未就绪，你将会看到 *Press to Refresh* 字样（或者是 "??" 字样，如果你选择的 Complication 样式比较小）。
3. 点击 Complication，进入对应的 Watch App。
4. 在 Watch App 中，点击 *City* 按钮选择城市。
5. 仍然在 Watch App 中，点击 *Refresh* 按钮触发第一次强制刷新。
6. 如果刷新成功，你会在按钮上方看到最新的空气污染数据。
7. 如果刷新缓慢，试试杀掉 app，从头开始。
8. 刷新成功以后，按压电子旋钮回到表盘。
9. 刷新成功并回到表盘时，你仍然可能看到不正常的 *Press to Refresh* 字样（或者 *??* 字样）。这是由于表盘 UI 刷新延迟造成的。你可以通过在多个不同表盘间来回切换的办法，强迫 WatchOS 刷新表盘。

###Auto-refresh is Implemented Using VOIP 后台自动刷新实现机制
* This app implements auto-refresh using the VOIP method. The minimum refresh interval is 10 minutes.
* The refresh will pause as soon as the current hour's readings are fetched. The refresh will resume automatically in the next hour.
* After you reboot your iPhone, you may need to use the watch app's refresh button to restart the companion iOS app's VOIP auto-refresh callback. 

[]()

* 后台自动刷新采用了 VOIP 接口实现。刷新的频率为 10 分钟一次。
* 因为数据源是每小时刷新一次。所以我们在刷新时，如果发现当前小时的数据已经取到了，刷新就会暂停。在进入下一个小时后，刷新会再次启动。
* 如果你重启了手机，VOIP 刷新可能会停止。你可以通过在 Watch App 中点击 *Refresh* 按钮的方式强迫唤醒 VOIP 刷新。

###Enable the Hiddeng Debug Mode 开启隐藏的 Debug 模式
* If you want to dive in and play around, go to the *CommonUtil.swift*, set *DEBUG_LOCAL_NOTIFICATION* to *true*. Delete and reinstall the app, debug information will start popping up from time to time as local notifications.
* 如果你想深入了解代码每时每刻的工作状况，去 *CommonUtil.swift* 里面，将 *DEBUG_LOCAL_NOTIFICATION* 设为 *true* 。删掉然后重装 app。代码的工作情况将会以本地通知的形式呈现在你眼前。



[beijing_aqi]: https://raw.githubusercontent.com/diwu/ui-markdown-store/master/aqi_3.jpg
[demo]: https://raw.githubusercontent.com/diwu/ui-markdown-store/master/watch_face_demo_3.jpg
[source]: http://www.stateair.net/web/post/1/4.html