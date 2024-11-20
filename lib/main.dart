import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:foodallergies_app/Examples.dart';
import 'package:foodallergies_app/notifications/notification.dart';
import 'package:foodallergies_app/wrapper.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init();
  tz.initializeTimeZones();

  runApp(const MaterialApp(home: Wrapper()));
}
