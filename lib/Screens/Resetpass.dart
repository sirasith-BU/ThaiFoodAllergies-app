import 'package:flutter/material.dart';
import 'package:foodallergies_app/auth/firebase_auth_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _auth = AuthService();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> saveResetpass() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;

      // ส่งลิงก์รีเซ็ตรหัสผ่าน
      await _auth.sendResetpasswordlink(email);

      // ดึง user_id จาก collection "user" โดยอ้างอิงจาก email
      final userSnapshot = await FirebaseFirestore.instance
          .collection("user")
          .where("email", isEqualTo: email)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userId = userSnapshot.docs[0].id;

        DateTime now = DateTime.now();
        String formattedDate =
            '${DateFormat('dd-MM').format(now)}-${(now.year + 543).toString()}';

        // บันทึกข้อมูลการรีเซ็ตรหัสผ่านใน collection "reset_password"
        await FirebaseFirestore.instance.collection("resetPassword").add({
          "user_id": userId,
          "email": email,
          "date": formattedDate,
          "time": DateFormat('HH:mm:ss').format(DateTime.now()), // เพิ่ม time
        });

        // แสดง AlertDialog เพื่อแจ้งผลลัพธ์
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("การรีเซ็ตรหัสผ่าน"),
            content: const Text(
                "ลิงค์สำหรับรีเซ็ตรหัสผ่าน ได้ถูกส่งไปยังอีเมลของคุณแล้ว"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // ปิด AlertDialog
                  Navigator.pop(context);
                },
                child: const Text("ตกลง"),
              ),
            ],
          ),
        );
      } else {
        // แสดงข้อผิดพลาดถ้าไม่พบ user_id ที่ตรงกับอีเมล
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("เกิดข้อผิดพลาด"),
            content: const Text("ไม่พบผู้ใช้งานที่มีอีเมลนี้ในระบบ"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("ตกลง"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "รีเซ็ตรหัสผ่าน",
                style: GoogleFonts.itim(
                  textStyle: const TextStyle(
                    fontSize: 66,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "อีเมลที่สมัครใช้บริการ",
                  labelStyle: GoogleFonts.itim(fontSize: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกอีเมล';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'กรุณากรอกอีเมลที่ถูกต้อง';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: saveResetpass,
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(const Size(350, 50)),
                  backgroundColor: WidgetStateProperty.all(Colors.green),
                ),
                child: Text(
                  "ดำเนินการ",
                  style: GoogleFonts.itim(
                    textStyle: const TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
