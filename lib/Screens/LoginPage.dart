import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodallergies_app/AdminScreens/Ad_MainPage.dart';
import 'package:foodallergies_app/Screens/MainPage.dart';
import 'package:foodallergies_app/auth/firebase_auth_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ResetPass.dart';
import 'RegisterPage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _auth = AuthService();

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = await _auth.loginUserWithEmailAndPassword(
          _email.text,
          _password.text,
        );

        if (user != null) {
          // ดึงข้อมูลผู้ใช้จาก Firestore
          final userDoc = await FirebaseFirestore.instance
              .collection('user') // ชื่อ collection ที่เก็บข้อมูลผู้ใช้
              .doc(user.uid) // ใช้ user.uid เพื่อค้นหาเอกสารของผู้ใช้
              .get();

          if (userDoc.exists) {
            final data = userDoc.data();
            // ตรวจสอบสถานะ isAdmin
            final isAdmin = data?['isAdmin'];
            if (isAdmin == true) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminMainPage()),
              );
              return; // หยุดกระบวนการต่อหลังไปยัง AdminMainPage
            }
          }
          // ถ้าไม่มีฟิลด์ isDisabled หรือ isAdmin หรือบัญชีไม่ถูกระงับ
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        }
      } on FirebaseAuthException catch (e) {
        // จัดการข้อผิดพลาด
        if (e.code == 'account-disabled') {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("บัญชีถูกระงับการใช้งาน"),
              content:
                  const Text("กรุณาติดต่อทีมสนับสนุนเพื่อขอข้อมูลเพิ่มเติม"),
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
        } else if (e.code == 'user-not-found') {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("ไม่สามารถเข้าสู่ระบบได้"),
              content: const Text("ไม่พบบัญชีผู้ใช้นี้"),
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
        } else if (e.code == 'account-deleted') {
          // เพิ่มกรณี account-deleted
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("บัญชีถูกลบแล้ว"),
              content: const Text(
                  "บัญชีนี้ถูกลบออกจากระบบแล้ว โปรดสร้างบัญชีใหม่หากต้องการใช้งานอีกครั้ง"),
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
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("ไม่สามารถเข้าสู่ระบบได้"),
              content: const Text("กรุณาตรวจสอบ อีเมล หรือ รหัสผ่าน อีกครั้ง"),
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
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              // โลโก้แอป
              Padding(
                padding: const EdgeInsets.all(0),
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: Image.asset(
                    'assets/foodallergies-logo.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // ฟิลด์อีเมล
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: TextFormField(
                  controller: _email,
                  decoration: InputDecoration(
                    labelText: "อีเมล",
                    labelStyle: GoogleFonts.itim(
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกอีเมล';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              // ฟิลด์รหัสผ่าน
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: TextFormField(
                  controller: _password,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "รหัสผ่าน",
                    labelStyle: GoogleFonts.itim(
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกรหัสผ่าน';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 4),
              // ลิงก์ลืมรหัสผ่าน
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ResetPasswordPage()),
                      );
                    },
                    child: Text(
                      "ลืมรหัสผ่าน?",
                      style: GoogleFonts.itim(
                        textStyle: const TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // ปุ่มเข้าสู่ระบบ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: ElevatedButton(
                  onPressed: _login,
                  style: ButtonStyle(
                    minimumSize: WidgetStateProperty.all(const Size(350, 50)),
                    backgroundColor: WidgetStateProperty.all(Colors.green),
                  ),
                  child: Text(
                    "เข้าสู่ระบบ",
                    style: GoogleFonts.itim(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                      ),
                    ),
                  ),
                ),
              ),
              // ข้อความยังไม่มีบัญชี
              Padding(
                padding: const EdgeInsets.only(top: 120),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "ยังไม่มีบัญชี?",
                      style: GoogleFonts.itim(
                        textStyle: const TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: 5),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Register()),
                        );
                      },
                      child: Text(
                        "สมัคร",
                        style: GoogleFonts.itim(
                          textStyle: const TextStyle(
                            color: Colors.green,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
