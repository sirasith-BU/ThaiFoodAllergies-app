import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EditUserDetailPage extends StatefulWidget {
  final String userId;

  const EditUserDetailPage({super.key, required this.userId});

  @override
  _EditUserDetailPageState createState() => _EditUserDetailPageState();
}

class _EditUserDetailPageState extends State<EditUserDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _aboutMeController = TextEditingController();

  bool _passwordVisible = false; // สถานะการมองเห็นรหัสผ่าน
  bool isDisabled = false; // สถานะการเปิด/ปิดการใช้งาน
  bool isAdmin = false; // สถานะ Admin
  bool? _newIsDisabled;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final snapshot =
        await _firestore.collection("user").doc(widget.userId).get();
    final userData = snapshot.data();
    if (userData != null) {
      setState(() {
        _usernameController.text = userData['username'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _passwordController.text = userData['password'] ?? '';
        _firstnameController.text = userData['firstname'] ?? '';
        _lastnameController.text = userData['lastname'] ?? '';
        _genderController.text = userData['gender'] ?? '';
        _birthdateController.text = userData['birthDate'] ?? '';
        _aboutMeController.text = userData['aboutMe'] ?? '';
        isDisabled = userData['isDisabled'] ?? false;
        isAdmin = userData['isAdmin'] ?? false;
      });
    }
  }

  Future<void> _saveUserDetails() async {
    final confirmation = await _showConfirmationDialog(
      title: "บันทึกข้อมูลผู้ใช้",
      content: "คุณต้องการบันทึกข้อมูลผู้ใช้นี้หรือไม่?",
    );
    if (confirmation) {
      await _firestore.collection("user").doc(widget.userId).update({
        'username': _usernameController.text,
        'email': _emailController.text,
        'firstname': _firstnameController.text,
        'lastname': _lastnameController.text,
        'gender': _genderController.text,
        'birthDate': _birthdateController.text,
        'aboutMe': _aboutMeController.text,
      });
      if (_newIsDisabled != null) {
        // ตรวจสอบว่า _newIsDisabled มีค่าหรือไม่
        await _firestore.collection("user").doc(widget.userId).update({
          'isDisabled': _newIsDisabled, // ใช้ค่าที่เก็บไว้ก่อนหน้านี้
        });
        setState(() {
          isDisabled =
              _newIsDisabled!; // อัพเดตสถานะใหม่ให้กับตัวแปร isDisabled
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("ข้อมูลผู้ใช้ถูกบันทึกแล้ว", style: GoogleFonts.itim()),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _toggleUserStatus() async {
    final confirmation = await _showConfirmationDialog(
      title: "เปลี่ยนสถานะผู้ใช้",
      content: isDisabled
          ? "คุณต้องการเปิดใช้งานบัญชีนี้หรือไม่?"
          : "คุณต้องการปิดใช้งานบัญชีนี้หรือไม่?",
    );
    if (confirmation) {
      setState(() {
        isDisabled = !isDisabled;
        _newIsDisabled = isDisabled; // เก็บสถานะใหม่ไว้
      });
    }
  }

  Future<void> moveUserDataToDeleteCollection(String userId) async {
    try {
      // แสดง AlertDialog เพื่อยืนยันก่อนลบ
      final confirmation = await _showConfirmationDialog(
        title: "ลบบัญชีผู้ใช้",
        content: "คุณต้องการลบบัญชีนี้หรือไม่?",
      );

      if (!confirmation) return; // ยกเลิกการลบหากผู้ใช้กด "ยกเลิก"

      // ดึงข้อมูลผู้ใช้จากคอลเล็กชัน 'user'
      final userSnapshot =
          await _firestore.collection("user").doc(userId).get();
      final userData = userSnapshot.data();

      if (userData != null) {
        // กำหนดเวลา del_dateTime ในรูปแบบ dd/MM/yyyy HH:mm:ss
        DateTime now = DateTime.now();
        String formattedDate =
            '${DateFormat('dd-MM').format(now)}-${(now.year + 543)} ${DateFormat('HH:mm:ss').format(now)}';

        // ย้ายข้อมูลไปที่ collection 'deleteUser' พร้อมเพิ่ม 'del_dateTime'
        await _firestore.collection('deleteUser').doc(userId).set({
          ...userData,
          'del_status': 'admin', // ระบุว่า admin เป็นผู้ลบ
          'del_dateTime': formattedDate, // วันที่และเวลาที่ลบ
        });

        // ลบข้อมูลจากคอลเล็กชัน 'user'
        await _firestore.collection('user').doc(userId).delete();

        // แสดงข้อความสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "ผู้ใช้ถูกลบเรียบร้อยแล้ว",
              style: GoogleFonts.itim(),
            ),
          ),
        );
        Navigator.pop(context, true);
      } else {
        // กรณีไม่พบข้อมูลในคอลเล็กชัน 'user'
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "ไม่พบข้อมูลผู้ใช้นี้ในระบบ",
              style: GoogleFonts.itim(),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      // จัดการข้อผิดพลาด
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "เกิดข้อผิดพลาด: ${e.toString()}",
            style: GoogleFonts.itim(),
          ),
        ),
      );
    }
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String content,
  }) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: GoogleFonts.itim()),
          content: Text(content, style: GoogleFonts.itim()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("ยกเลิก", style: GoogleFonts.itim()),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("ยืนยัน", style: GoogleFonts.itim()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("แก้ไขข้อมูลผู้ใช้", style: GoogleFonts.itim(fontSize: 24)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "ชื่อผู้ใช้",
                  labelStyle: GoogleFonts.itim(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstnameController,
                      decoration: InputDecoration(
                        labelText: "ชื่อจริง",
                        labelStyle: GoogleFonts.itim(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastnameController,
                      decoration: InputDecoration(
                        labelText: "นามสกุล",
                        labelStyle: GoogleFonts.itim(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "อีเมล",
                  labelStyle: GoogleFonts.itim(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "รหัสผ่าน",
                  labelStyle: GoogleFonts.itim(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _genderController,
                decoration: InputDecoration(
                  labelText: "เพศ",
                  labelStyle: GoogleFonts.itim(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _birthdateController,
                decoration: InputDecoration(
                  labelText: "วันเกิด",
                  labelStyle: GoogleFonts.itim(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aboutMeController,
                decoration: InputDecoration(
                  labelText: "เกี่ยวกับฉัน",
                  labelStyle: GoogleFonts.itim(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isAdmin ? Colors.orange : Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAdmin ? "ผู้ดูแลระบบ" : "ผู้ใช้ทั่วไป",
                        style:
                            GoogleFonts.itim(color: Colors.white, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SwitchListTile(
                      activeColor: Colors.green,
                      title: Text(
                        isDisabled
                            ? "เปิดการใช้งานบัญชีผู้ใช้"
                            : "ปิดใช้งานบัญชีผู้ใช้",
                        style: GoogleFonts.itim(),
                      ),
                      value: !isDisabled,
                      onChanged: (value) {
                        setState(() {
                          _toggleUserStatus();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveUserDetails,
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(const Size(150, 50)),
                  backgroundColor: WidgetStateProperty.all(Colors.orange),
                ),
                child: Text(
                  "บันทึก",
                  style: GoogleFonts.itim(fontSize: 26, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await moveUserDataToDeleteCollection(widget.userId);
                },
                child: Text(
                  "ลบบัญชี",
                  style: GoogleFonts.itim(fontSize: 18, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
