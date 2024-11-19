import 'package:flutter/material.dart';
import 'package:foodallergies_app/notifications/notification.dart';

class NotificationExample extends StatefulWidget {
  const NotificationExample({super.key});

  @override
  State<NotificationExample> createState() => _NotificationExampleState();
}

class _NotificationExampleState extends State<NotificationExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  NotificationService.showInstantNotification(
                      'Instant Notification',
                      'This shows an instant notification');
                },
                child: const Text("Show notification")),
            const SizedBox(
              height: 12,
            ),
            ElevatedButton(
                onPressed: () {
                  DateTime scheduledDate =
                      DateTime.now().add(const Duration(seconds: 5));
                  NotificationService.scheduleNotification(
                      'Schedule Notofication',
                      "this notofocation is schedueld",
                      scheduledDate);
                },
                child: const Text("Schedule Notification")),
          ],
        ),
      ),
    );
  }
}
