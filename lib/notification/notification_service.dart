import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  static final notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future init({bool initScheduled = false}) async {
    const initializationSettingsAndroid = AndroidInitializationSettings('ic_notification');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS);
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
      },

      // onSelectNotification: selectNotification
    );

    if(initScheduled){
      tz.initializeTimeZones();
      final location = await FlutterNativeTimezone.getLocalTimezone();
      print("location : ${location.toString()}");
      print("location India: ${location[1]}");
      print("location India 2: ${location[2]}");
      //tz.setLocalLocation(tz.getLocation('America/Detroit'));
      tz.setLocalLocation(tz.getLocation(location[2].toString()));
    }
  }

  static Future selectNotification(String payload) async {
    //Handle notification tapped logic here
    /*onNotifications.add(payload);*/
  }


  // Local Notification
  static showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      notifications.show(id, title, body, await notificationDetails(),
          payload: payload);


  //ScheduleNotification
  static showScheduleNotification({
    int id = 1,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduleDate,
  }) async =>
      notifications.zonedSchedule(
          id, title, body,
          //daily Basis
          _scheduleDaily(const Time(6)),

          // weekly
          //_scheduleWeekly(Time(5,16,0),days:[DateTime.monday, DateTime.wednesday, DateTime.friday]),

          //for spacific time
          //tz.TZDateTime.from(scheduleDate,tz.getLocation('America/Detroit')),
          await notificationDetails(),
          payload: payload,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,          // daily basis
          //daily basis
          matchDateTimeComponents: DateTimeComponents.time

          //weekly basis
          //matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime
      );

  //DailyScheduleNotification
/*  static showDailyScheduleNotification({
    int id = 12,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduleDate,
  }) async =>
      notifications.showDailyAtTime(
          id, title, body,
          //daily Basis
          const Time(4,14,0),
          //_scheduleDaily(const Time(3,55,0)),


          await notificationDetails(),
          payload: payload,
         // androidAllowWhileIdle: true,
          //uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,          // daily basis
          //daily basis
          //matchDateTimeComponents: DateTimeComponents.time

        //weekly basis
        //matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime
      );*/

  //periodically Notification
  static showPeriodicallyNotification({
    int id = 2,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduleDate,
  }) async =>
      notifications.periodicallyShow(
        id, title, body,
        RepeatInterval.everyMinute,
        await notificationDetails(),
        payload: payload,
        androidAllowWhileIdle: true,
      );

  //this use when set Daily basis notification set
  static  tz.TZDateTime _scheduleDaily(Time time){
    final now = tz.TZDateTime.now(tz.local /*  getLocation('Asia/Kolkata')*/);
    final scheduleDate = tz.TZDateTime(tz.local/*tz.getLocation('Asia/Kolkata')*/,
      now.year, now.month, now.day,
      time.hour, time.minute, time.second,
    );
    return scheduleDate.isBefore(now)
        ? scheduleDate.add(const Duration(days: 1))
        : scheduleDate;
  }

  //this use when set Week basis notification set
  static  tz.TZDateTime _scheduleWeekly(Time time, {required List<int> days}) {
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
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channel id',
        'channel name',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        ticker: 'ticker',
        enableLights: true,
        channelShowBadge: true,

        // largeIcon: DrawableResourceAndroidBitmap('justwater'),
        // styleInformation: BigPictureStyleInformation(
        //   FilePathAndroidBitmap('justwater'),
        //   hideExpandedLargeIcon: false,
        // ),
        // color:  Color(0xff2196f3),
      ),
    );
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
