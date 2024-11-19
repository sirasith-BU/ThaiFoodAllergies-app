import 'package:flutter/material.dart';
import 'package:foodallergies_app/Screens/MainPage.dart';
import 'package:foodallergies_app/auth/firebase_auth_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Resetpass.dart';
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

  gotoMain(BuildContext context) => Navigator.push(
      context, MaterialPageRoute(builder: (context) => const MainPage()));

  _login() async {
    if (_formKey.currentState!.validate()) {
      final user = await _auth.loginUserWithEmailAndPassword(
          _email.text, _password.text);

      if (user != null) {
        gotoMain(context);
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
                padding: const EdgeInsets.all(13),
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: Image.asset(
                    'assets/foodallergies-logo.png',
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
                            builder: (context) => const ResetPass()),
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
              const SizedBox(height: 20),
              // ข้อความยังไม่มีบัญชี
              Padding(
                padding: const EdgeInsets.only(top: 130),
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
