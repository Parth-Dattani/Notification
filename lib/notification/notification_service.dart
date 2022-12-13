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
    const initializationSettingsAndroid = AndroidInitializationSettings('launch_background');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS);

    // void onSelect(NotificationResponse notificationResponse) {
    //   // ignore: avoid_print
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

    await notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) {
        if (payload != null && payload.toString().isNotEmpty) {
          onNotifications.add(payload.toString());
          print("onNotifications value : $onNotifications");
        }
      },
      //selectNotification(payload)async {}
    );

    await notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) async {
        onNotifications.add(payload.toString());
      },
      // onSelectNotification: selectNotification
    );

    if(initScheduled){
      tz.initializeTimeZones();
      final location = await FlutterNativeTimezone.getAvailableTimezones();
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
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduleDate,
  }) async =>
      notifications.zonedSchedule(
          id, title, body,
          //daily Basis
          //_schedulDaily(const Time(11)),

          // weekly
          //_scheduleweekly(Time(3),days:[DateTime.monday, DateTime.friday]),

          //for spacific time
          tz.TZDateTime.from(scheduleDate,tz.getLocation('America/Detroit')),
          await notificationDetails(),
          payload: payload,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,          // daily basis
          //daily basis
           // matchDateTimeComponents: DateTimeComponents.time

          //weekly basis
          //matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime
      );


  //try periodically
  static showPeriodicallyNotification({
    int id = 0,
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
  static  tz.TZDateTime _schedulDaily(Time time){
    final now = tz.TZDateTime.now(tz.getLocation('America/Detroit'));
    final scheduleDate = tz.TZDateTime(
        tz.getLocation('America/Detroit'),
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
  static  tz.TZDateTime _scheduleweekly(Time time, {required List<int> days}) {
    tz.TZDateTime scheduledDate = _schedulDaily(time);

    while (!days.contains(scheduledDate.weekday)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }
    return scheduledDate;
  }




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
