import 'package:flutter/material.dart';
import 'notification_service.dart';
import 'second_notification.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    NotificationService.init(initScheduled: true);
    listenNotification();

    NotificationService.showScheduleNotification(
            title: 'Hello',
            body: 'Good Morning',
            payload: 'good_morning',
            scheduleDate: DateTime.now().add(const Duration(seconds: 10)));
  }

  void listenNotification() {
    NotificationService.onNotifications.stream.listen(onClickedNotification);
  }

  void onClickedNotification(String? payload) =>
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MySecondScreen(
                payload: payload,
              )));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Demo"),
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 100),
            // Update with local image
            child: Image.asset("assets/Images/imgLogo.png", scale: 0.6),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  NotificationService.showNotification(
                    title: "E-commerce",
                    body: "Hello, user this for only Testing purpose.",
                    payload: "E-commerce",
                  );
                },
                child: const Text("Notification Now"),
              ),
              ElevatedButton(
                  onPressed: () {
                    NotificationService.showScheduleNotification(
                        title: 'Good Morning',
                        body: 'How R U, User',
                        payload: 'good_morning',
                        scheduleDate: DateTime.now().add(const Duration(seconds: 10)),
                    );
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text(
                            "An Notification has been sent in 10 Seconds",
                            style: TextStyle(fontSize: 16),
                          ),
                        ));

                  }, child: const Text("Schedule  Notification"))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(onPressed: () {
                NotificationService.showPeriodicallyNotification(
                  title: 'Good Morning',
                  body: 'How R U, users This is Periodically Notification',
                  payload: 'good_morning',
                  scheduleDate: DateTime.now().add(const Duration(seconds: 10)),
                );
              }, child: const Text("Notification periodically")),
              ElevatedButton(onPressed: () {
                NotificationService.showScheduleNotification(
                  title: 'Good Evening',
                  body: 'How R U, users This is Daily Notification',
                  payload: 'good_morning',
                  scheduleDate: DateTime.now().add(const Duration(seconds: 10)),
                );
              }, child: const Text("Notification Daily")),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(onPressed: () {
                NotificationService.cancelSingleNotifications();
              }, child: const Text("Cancel  Notification",)),
              ElevatedButton(onPressed: () {
                NotificationService.cancelAllNotifications();
              }, child: const Text("Cancel All  Notification",))
            ],
          ),
        ],
      ),
    );
  }
}
