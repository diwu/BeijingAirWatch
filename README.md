![][demo]

###WatchOS 2.0 Customized Complication for Real-time Air Quality Readings of Major Chinese Cities 苹果表盘实时刷新北上广沈蓉空气质量
* Real-time PM 2.5 readings for major Chinese cities right on your clock face.
* Supports Shanghai, Beijing, Guangzhou, Shenyang and Chengdu.
* Will auto-refresh within 10 minutes when the latest hourly readings are out.
* A clean and consice complication widget that fits perfectly on your clock face.


###Don't Take Clean Air for Granted 别把空气质量不当回事

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

###How to Set-up the Complication 如何设置表盘复杂功能
1. Go to your watch. Force touch to customize. Find the complication named *PM2.5*.
2. If the reading is not ready yet, you will see *Press to Refresh*. 
3. Press the complication to see the watch app.
4. In the watch app, press the *City* button to select your city.
5. Also in the watch app, press the *Refresh* button to force-start the initial refresh. 
6. When the watch app is done refreshing, you will find meaningful data displayed right above the refresh and city buttons.
7. If the refresh takes too long to finish, try kill the app and start all over. 
8. When the refresh is done, hit the digital crown to go back to the clock face. 
9. It's possible that when back to the clock face, you are still seeing the *Press to Refresh* text instead of the air quality reading. If that's the case, force touch to switch to another clock face that doesn't have this complication, and then switch back. By now you should see the correct reading.

###Auto-refresh is Implemented Using VOIP 后台自动刷新实现机制
* This app implements auto-refresh using the VOIP method. The minimum refresh interval is 10 minutes.
* The refresh will pause as soon as the current hour's readings are fetched. The refresh will resume automatically in the next hour.
* After you reboot your iPhone, you may need to use the watch app's refresh button to restart the companion iOS app's VOIP auto-refresh callback. 



[beijing_aqi]: https://raw.githubusercontent.com/diwu/ui-markdown-store/master/aqi_3.jpg
[demo]: https://raw.githubusercontent.com/diwu/ui-markdown-store/master/watch_face_demo_3.jpg
[source]: http://www.stateair.net/web/post/1/4.html