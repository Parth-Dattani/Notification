import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import 'notification/notification.dart';
import 'notification/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(
      null,
     [
      NotificationChannel(
          channelKey: 'channelKey1',
          channelName: 'Notification',
          channelDescription: 'channelDescription demo',
          ledColor: Colors.red,
          defaultColor: Colors.teal,
        playSound: true,
        enableVibration: true,
        soundSource: 'resource://raw/res_custom_notification',
        //soundSource: 'resource://raw/whistle',
      )
     ]
  );
  NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notification Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}


