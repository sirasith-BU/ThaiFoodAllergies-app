import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodallergies_app/Screens/LoginPage.dart';
import 'package:foodallergies_app/Screens/MainPage.dart';
import 'AdminScreens/Ad_MainPage.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error"));
          } else {
            if (snapshot.data == null) {
              // ถ้าผู้ใช้ยังไม่ได้ล็อกอิน ให้ไปหน้า LoginPage
              return const Login();
            } else {
              // ถ้าผู้ใช้ล็อกอินแล้ว ให้ดึงข้อมูล admin จาก Firestore
              final User user = snapshot.data!;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('user') // ชื่อ collection ที่เก็บข้อมูล user
                    .doc(user.uid) // ดึงข้อมูลของผู้ใช้คนปัจจุบัน
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (userSnapshot.hasError) {
                    return const Center(child: Text("Error loading user data"));
                  } else {
                    // ตรวจสอบข้อมูล admin ใน Firestore
                    final data =
                        userSnapshot.data?.data() as Map<String, dynamic>?;
                    if (data == null || data['isAdmin'] == null) {
                      // ถ้าไม่มีข้อมูล admin หรือไม่ได้ตั้งค่า admin ใน Firestore
                      return const Center(child: Text("Invalid user data"));
                    } else if (data['isAdmin'] == true) {
                      // ถ้า admin เป็น true ให้ไปหน้า AdminMainPage
                      return const AdminMainPage();
                    } else {
                      // ถ้า admin เป็น false ให้ไปหน้า MainPage
                      return const MainPage();
                    }
                  }
                },
              );
            }
          }
        },
      ),
    );
  }
}
