import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final List<Map<String, String>> notifications = [
    {
      'title': 'สมหมาย รักคุณเท่าฟ้า',
      'description': 'ได้แสดงความคิดเห็น',
      'image': 'https://via.placeholder.com/150'
    },
    {
      'title': 'สมชาย รักคุณเท่าดิน',
      'description': 'ได้แสดงความคิดเห็น',
      'image': 'https://via.placeholder.com/150'
    },
    {
      'title': 'สมรักษ์ รักคุณเท่าน้ำ',
      'description': 'ได้แสดงความคิดเห็น',
      'image': 'https://via.placeholder.com/150'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text('การแจ้งเตือน',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
        backgroundColor: Colors.green,
        actions: const [
          Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.notifications, color: Colors.white)),
        ],
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                leading: Image.network(
                  notification['image']!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(
                  notification['title']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(notification['description']!),
              ),
            ),
          );
        },
      ),
    );
  }
}
