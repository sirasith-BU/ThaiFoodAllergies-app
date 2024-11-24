import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodallergies_app/Screens/TermsAndConditionsPage.dart';
import 'package:foodallergies_app/auth/firebase_auth_services.dart';
import 'package:google_fonts/google_fonts.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _auth = AuthService();

  final _name = TextEditingController();
  final _firstName = TextEditingController();
  final _surname = TextEditingController();
  final _email = TextEditingController();
  final _remail = TextEditingController();
  final _password = TextEditingController();
  final _rpassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _showPassword = false;
  bool _showRpassword = false;
  String? _gender;
  DateTime? _birthDate;

  final CollectionReference _usercollection =
      FirebaseFirestore.instance.collection("user");

  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _firstName.dispose();
    _surname.dispose();
    _email.dispose();
    _remail.dispose();
    _password.dispose();
    _rpassword.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      final user = await _auth.createUserWithEmailAndPassword(
        _email.text,
        _password.text,
      );

      // ตรวจสอบว่าอีเมลมีอยู่แล้วใน Firestore
      QuerySnapshot snapshot =
          await _usercollection.where('email', isEqualTo: _email.text).get();
      if (snapshot.docs.isNotEmpty) {
        // แสดง AlertDialog ถ้ามีผู้ใช้ที่มีอีเมลนี้อยู่แล้ว
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("ไม่สามารถสร้างบัญชีผู้ใช้ได้"),
            content: const Text("มีผู้ใช้ที่มีอีเมลนี้อยู่แล้ว"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // ปิด AlertDialog
                },
                child: const Text("ตกลง"),
              ),
            ],
          ),
        );
      } else if (user != null) {
        // แปลงวันที่เกิดเป็นรูปแบบ dd-mm-yyyy
        String? birthDateString = _birthDate != null
            ? "${_birthDate!.day.toString().padLeft(2, '0')}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.year}"
            : null;

        // เพิ่มผู้ใช้ลงใน Firestore พร้อม user_id
        await _usercollection.doc(user.uid).set({
          // ใช้ user.uid เป็น document ID
          "user_id": user.uid, // เพิ่ม user_id
          "username": _name.text,
          "firstname": _firstName.text,
          "lastname": _surname.text,
          "gender": _gender, // เปลี่ยนเป็น text ถ้าจำเป็น
          "birthDate": birthDateString,
          "email": _email.text,
          "password": _password.text,
          "admin": false
        });

        // เปลี่ยนไปยังหน้าถัดไป
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const TermsAndConditionsPage()),
        );
      }
    }
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
              const SizedBox(height: 50),
              Text(
                "สร้างบัญชีผู้ใช้",
                style: GoogleFonts.itim(
                    textStyle: const TextStyle(
                        fontSize: 50, fontWeight: FontWeight.bold)),
              ),
              // const SizedBox(height: 20),
              // ชื่อจริงและนามสกุล
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstName,
                        decoration: InputDecoration(
                            labelText: "ชื่อจริง",
                            labelStyle: GoogleFonts.itim(
                                textStyle: const TextStyle(fontSize: 18))),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "กรุณากรอกชื่อจริง";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _surname,
                        decoration: InputDecoration(
                            labelText: "นามสกุล",
                            labelStyle: GoogleFonts.itim(
                                textStyle: const TextStyle(fontSize: 18))),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "กรุณากรอกนามสกุล";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // เพศและวันเกิด
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "เพศ",
                          labelStyle: GoogleFonts.itim(
                              textStyle: const TextStyle(fontSize: 18)),
                        ),
                        value: _gender,
                        items: const [
                          DropdownMenuItem(value: "ชาย", child: Text("ชาย")),
                          DropdownMenuItem(value: "หญิง", child: Text("หญิง")),
                          DropdownMenuItem(
                              value: "อื่นๆ", child: Text("อื่นๆ")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _gender = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "กรุณาเลือกเพศ";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "วันเกิด",
                          labelStyle: GoogleFonts.itim(
                              textStyle: const TextStyle(fontSize: 18)),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              setState(() {
                                _birthDate = pickedDate;
                              });
                                                        },
                          ),
                        ),
                        controller: TextEditingController(
                            text: _birthDate != null
                                ? "${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}"
                                : ""),
                        validator: (value) {
                          if (_birthDate == null) {
                            return "กรุณาเลือกวันเกิด";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // ชื่อผู้ใช้
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  controller: _name,
                  decoration: InputDecoration(
                      labelText: "ชื่อผู้ใช้",
                      labelStyle: GoogleFonts.itim(
                          textStyle: const TextStyle(fontSize: 18))),
                ),
              ),
              const SizedBox(height: 20),
              // อีเมลและยืนยันอีเมล
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _email,
                      decoration: InputDecoration(
                          labelText: "อีเมล",
                          labelStyle: GoogleFonts.itim(
                              textStyle: const TextStyle(fontSize: 18))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "กรุณากรอกอีเมล";
                        }
                        if (_email.text != _remail.text) {
                          return "อีเมลไม่ตรงกัน";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _remail,
                      decoration: InputDecoration(
                          labelText: "ยืนยันอีเมล",
                          labelStyle: GoogleFonts.itim(
                              textStyle: const TextStyle(fontSize: 18))),
                      validator: (value) {
                        if (_email.text != value) {
                          return "อีเมลไม่ตรงกัน";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // รหัสผ่านและยืนยันรหัสผ่าน
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _password,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: "รหัสผ่าน",
                        labelStyle: GoogleFonts.itim(
                            textStyle: const TextStyle(fontSize: 18)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "กรุณากรอกรหัสผ่าน";
                        }
                        if (_password.text != _rpassword.text) {
                          return "รหัสผ่านไม่ตรงกัน";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _rpassword,
                      obscureText: !_showRpassword,
                      decoration: InputDecoration(
                        labelText: "ยืนยันรหัสผ่าน",
                        labelStyle: GoogleFonts.itim(
                            textStyle: const TextStyle(fontSize: 18)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showRpassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _showRpassword = !_showRpassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (_password.text != value) {
                          return "รหัสผ่านไม่ตรงกัน";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // ปุ่มสมัคร
              ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 10)),
                child: Text("สมัครสมาชิก",
                    style: GoogleFonts.itim(
                        textStyle: const TextStyle(
                            fontSize: 24, color: Colors.white))),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("มีบัญชีอยู่แล้ว?",
                        style: GoogleFonts.itim(
                            textStyle: const TextStyle(fontSize: 22))),
                    const SizedBox(width: 5),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "เข้าสู่ระบบ",
                        style: GoogleFonts.itim(
                            textStyle: const TextStyle(
                                color: Colors.green, fontSize: 22)),
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
