
import 'dart:io';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  static Future init({bool initScheduled = false}) async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification',);

    const initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      defaultPresentAlert: true,

    );
    const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    void onDidReceiveLocalNotification(
        int id, String? title, String? body, String? payload) {
      print('id $id');
    }
    // void onSelect(NotificationResponse notificationResponse) {
    //
    //   print('notification(${notificationResponse.id}) '
    //       'action tapped: ''${notificationResponse.actionId} with'
    //       ' payload res: ${notificationResponse.payload}');
    //   if (notificationResponse.input?.isNotEmpty ?? false) {
    //     print('notification action tapped with input:'' ${notificationResponse.input}');
    //   }
    // }
    /*void selectNotification(String? payload) {
      if (payload != null && payload.isNotEmpty) {
        onNotifications.add(payload.toString());
      }
      print("dfgdfg : $onNotifications");
    }*/

    // await notifications.initialize(
    //   initializationSettings,
    //   onDidReceiveNotificationResponse: (payload) {
    //     if (payload != null && payload.toString().isNotEmpty) {
    //       onNotifications.add(payload.toString());
    //       print("onNotifications value : $onNotifications");
    //     }
    //   },
    //   //selectNotification(payload)async {}
    // );

    await notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) async {
        onNotifications.add(payload.toString());
        print("onNotifications value : $onNotifications");
        print("pay load on Did Receive $payload");
      },
      // onSelectNotification: selectNotification
    );

    if (initScheduled) {
      tz.initializeTimeZones();
      final location = await FlutterNativeTimezone.getLocalTimezone();
      print("location : ${location.toString()}");
      print("location India: ${location[1]}");
      print("location India 2: ${location[2]}");
      tz.setLocalLocation(tz.getLocation('America/Detroit'));
      //tz.setLocalLocation(tz.getLocation(location.toString()));
    }
  }

  void selectNotification(String payload) async {
    //Handle notification tapped logic here
    /*onNotifications.add(payload);*/
    print(payload);
  }


  static awesomeNoti()async{
    String time = await AwesomeNotifications().getLocalTimeZoneIdentifier();
      AwesomeNotifications().createNotification(

        content: NotificationContent(
            id: 12,
            channelKey: 'channelKey1',
          title: 'Awesome Notification',
          body: 'this is Awesome Notification',
          bigPicture: "https://media.istockphoto.com/id/1194343598/vector/bright-modern-mega-sale-banner-for-advertising-discounts-vector-template-for-design-special.jpg?s=612x612&w=0&k=20&c=oxeukxA1kVLBuLtcbipu_94blsVGs9eU0V_x70wkVzA=",
          notificationLayout: NotificationLayout.BigPicture,
        ),
        actionButtons: <NotificationActionButton>[
          NotificationActionButton(key: 'accept', label: 'Accept'),
          NotificationActionButton(key: 'reject', label: 'Reject'),
        ],
     //      schedule: NotificationInterval(
     //     interval: 5,
     //     timeZone: time,
     //     repeats: true
     // )
     );
  }

  //1. Local Notification
  static showNotification({
    required int id,
    String? title,
    String? body,
    String? payload,
  }) async =>
      notifications.show(id, title, body, payload: payload, await notificationDetails());

  static/* Future<void>*/ showDailyAtTime({
    required int id,
    String? title,
    String? body,
    String? payload,
  }) async {
    var time = const Time(10, 59, 0); // var androidChannelSpecifics = const AndroidNotificationDetails(
    //   'CHANNEL_ID 4',
    //   'CHANNEL_NAME 4',
    //   importance: Importance.max,
    //   priority: Priority.high,
    // );
    // var iosChannelSpecifics = DarwinNotificationDetails();
    // var platformChannelSpecifics = NotificationDetails(android: androidChannelSpecifics,iOS:  iosChannelSpecifics);
    await notificationDetails();
    await notifications.showDailyAtTime(
      id,
      'Test Title at ${time.hour}:${time.minute}.${time.second}',
      body, //null
      time,
      await notificationDetails(),
      payload: payload,
    );
  }


  //2. ScheduleNotification
  static showScheduleNotification({
    required int id,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduleDate,
  }) async =>
      notifications.zonedSchedule(
          id,
          title,
          body,
          //2.1 daily Basis
          _scheduleDaily(const Time(10,56,00)),

          //2.2 weekly
          //_scheduleWeekly(Time(5,16,0),days:[DateTime.monday, DateTime.wednesday, DateTime.friday]),

          //2.3 for spacific time
          //tz.TZDateTime.from(scheduleDate,tz.getLocation('America/Detroit')),
          await notificationDetails(),
          payload: payload,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime, // daily basis
          //daily basis
          matchDateTimeComponents: DateTimeComponents.time

          //weekly basis
          //matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime
          );



  static ActiveReq({
    String? title,
    //var pendingNotificationRequest  =
  }) async { notifications.getActiveNotifications();
  print("Active Notification : ${notifications.getActiveNotifications()}");
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications () async {
    print("pending Notification : ${notifications.pendingNotificationRequests}");
    return await notifications.pendingNotificationRequests();

  }

  static Future<ScaffoldMessengerState> getPendingNotificationCount(context) async {
    List<PendingNotificationRequest> count =
    await notifications.pendingNotificationRequests();
    print("pending count ${count.length}");

return
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
           SnackBar(
            content: Text(
               "Pending Notification : ${count.length}",
              style: const TextStyle(fontSize: 16),
            ),
          ));
  }

  static pendingReq({
    String? title,
    //var pendingNotificationRequest  =
}) async { notifications.pendingNotificationRequests();

  print("pending Notification : ${notifications.pendingNotificationRequests}");
  }

  //3. periodically Notification
  static showPeriodicallyNotification({
    required int id,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduleDate,
  }) async =>
      notifications.periodicallyShow(
        id,
        title,
        body,
        RepeatInterval.everyMinute,
        await notificationDetails(),
        payload: payload,
        androidAllowWhileIdle: true,
      );

  //4. group
  static showGroupedNotifications({
    required String title,
  }) async {
    final platformChannelSpecifics = await notificationDetails();
    final groupedPlatformChannelSpecifics = await _groupedNotificationDetails();
    await notifications.show(
      0,
      "Parth",
      "Hello",
      platformChannelSpecifics,
    );
    await notifications.show(
      1,
      "Parth",
      "Good Morning",
      platformChannelSpecifics,
    );
    await notifications.show(
      3,
      "Parth",
      "How Are You?",
      platformChannelSpecifics,
    );
    await notifications.show(
      4,
      "Yash",
      "Hii",
      Platform.isIOS
          ? groupedPlatformChannelSpecifics
          : platformChannelSpecifics,
    );
    await notifications.show(
      5,
      "Parth",
      "Are You There",
      Platform.isIOS
          ? groupedPlatformChannelSpecifics
          : platformChannelSpecifics,
    );
    await notifications.show(
      6,
      Platform.isIOS ? "group 2" : "Attention",
      Platform.isIOS ? "Third drink" : "5 missed drinks",
      groupedPlatformChannelSpecifics,
    );
  }

  //gropu ss2222
  static _groupedNotificationDetails() {
    const List<String> lines = <String>[
      'group 1 Hello',
      'group 1   Good Morning',
      'group 1   How Are You?',
      'group 2 Hii',
      'group 2   Are You There'
    ];

    const InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
        lines,
        contentTitle: '5 messages',
        summaryText: 'missed messages');
    AndroidNotificationDetails androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'channel id',
      'channel name',
      groupKey: 'com.example.flutter_push_notifications',
      channelDescription: 'channel description',
      setAsGroupSummary: true,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      ticker: 'ticker',
      styleInformation: inboxStyleInformation,
      color: Color(0xff2196f3),
    );
  }

  //this use when set Daily basis notification set
  static tz.TZDateTime _scheduleDaily(Time time) {
    final now = tz.TZDateTime.now(tz.local /*  getLocation('Asia/Kolkata')*/);
    final scheduleDate = tz.TZDateTime(
      tz.local /*tz.getLocation('Asia/Kolkata')*/,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      time.second,
    );
    return scheduleDate.isBefore(now)
        ? scheduleDate.add(const Duration(days: 1))
        : scheduleDate;
  }

  //this use when set Week basis notification set
  static tz.TZDateTime _scheduleWeekly(Time time, {required List<int> days}) {
    tz.TZDateTime scheduledDate = _scheduleDaily(time);

    while (!days.contains(scheduledDate.weekday)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  //cancel notification pass id which notification you want to clear
  static void cancelSingleNotifications() => notifications.cancel(1);

  //cancel All notification
  static void cancelAllNotifications() => notifications.cancelAll();

  //this methode is use for any local notification
  static Future notificationDetails() async {
    //final bigPicture = ImagePath.profileLogo;

    const androidNotificationDetails = AndroidNotificationDetails(
      'channel id',
      'channel name',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      ticker: 'ticker',
      enableLights: true,
      channelShowBadge: true,
      sound: RawResourceAndroidNotificationSound('whistle'),

      // largeIcon: DrawableResourceAndroidBitmap('justwater'),
      // styleInformation: BigPictureStyleInformation(
      //   FilePathAndroidBitmap('justwater'),
      //   hideExpandedLargeIcon: false,
      // ),
      // color:  Color(0xff2196f3),
    );
    const iosNotificationDetails = DarwinNotificationDetails();
    return const NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails);
  }
}

/*import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//import 'package:flutter_push_notifications/utils/download_util.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService();

  final _localNotifications = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String> behaviorSubject = BehaviorSubject();

  Future<void> initializePlatformNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_stat_justwater');

    // final IOSInitializationSettings initializationSettingsIOS =
    // IOSInitializationSettings(
    //     requestSoundPermission: true,
    //     requestBadgePermission: true,
    //     requestAlertPermission: true,
    //     onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
     // iOS: initializationSettingsIOS,
    );

    // await _localNotifications.initialize(initializationSettings,
    //     onSelectNotification: selectNotification);
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    print('id $id');
  }
  void selectNotification(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      behaviorSubject.add(payload);
    }
  }
}*/

////shoGroup
/*static _groupedNotificationDetails() {
  const List<String> lines = <String>[
    'group 1 First drink',
    'group 1   Second drink',
    'group 1   Third drink',
    'group 2 First drink',
    'group 2   Second drink'
  ];

  const InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
      lines,
      contentTitle: '5 messages',
      summaryText: 'missed drinks');
  AndroidNotificationDetails androidPlatformChannelSpecifics =
  const AndroidNotificationDetails(
    'channel id',
    'channel name',
    groupKey: 'com.example.flutter_push_notifications',
    channelDescription: 'channel description',
    setAsGroupSummary: true,
    importance: Importance.max,
    priority: Priority.max,
    playSound: true,
    ticker: 'ticker',
    styleInformation: inboxStyleInformation,
    color: Color(0xff2196f3),
  );



}*/
