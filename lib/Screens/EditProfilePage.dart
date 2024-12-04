import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodallergies_app/Screens/LoginPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../auth/firebase_auth_services.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _auth = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _aboutmeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore.collection("user").doc(user.uid).get();
      final userData = snapshot.data();
      if (userData != null) {
        _usernameController.text = userData['username'] ?? '';
        _firstNameController.text = userData['firstname'] ?? '';
        _lastNameController.text = userData['lastname'] ?? '';
        _genderController.text = userData['gender'] ?? '';
        _birthdateController.text = userData['birthDate'] ?? '';
        _aboutmeController.text = userData['aboutMe'] ?? '';
      }
    }
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection("user").doc(user.uid).update({
        'username': _usernameController.text,
        'firstname': _firstNameController.text,
        'lastname': _lastNameController.text,
        'gender': _genderController.text,
        'birthDate': _birthdateController.text,
        'aboutMe': _aboutmeController.text
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("การแก้ไขโปรไฟล์เสร็จสิ้น", style: GoogleFonts.itim())),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      // แสดง dialog เพื่อยืนยันการลบบัญชี
      final confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("ยืนยันการลบบัญชี", style: GoogleFonts.itim()),
            content: Text("คุณแน่ใจหรือไม่ว่าต้องการลบบัญชีนี้?",
                style: GoogleFonts.itim()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // ผู้ใช้กดไม่ลบ
                },
                child: Text("ยกเลิก", style: GoogleFonts.itim()),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // ผู้ใช้กดยืนยันลบ
                },
                child: Text("ลบ", style: GoogleFonts.itim()),
              ),
            ],
          );
        },
      );

      // ถ้าผู้ใช้ยืนยันจะลบบัญชี
      if (confirmDelete ?? false) {
        // ย้ายข้อมูลของผู้ใช้ไปยังคอลเล็กชัน deleteUser
        final userSnapshot =
            await _firestore.collection("user").doc(user.uid).get();
        final userData = userSnapshot.data();
        if (userData != null) {
          // กำหนดเวลา del_dateTime ในรูปแบบ dd/MM/yyyy HH:mm:ss
          DateTime now = DateTime.now();
          String formattedDate =
              '${DateFormat('dd-MM').format(now)}-${(now.year + 543)} ${DateFormat('HH:mm:ss').format(now)}';

          // ย้ายข้อมูลไปที่ collection 'deleteUser' พร้อมเพิ่ม 'del_dateTime'
          await _firestore.collection('deleteUser').doc(user.uid).set({
            ...userData,
            'del_status': 'user', // ตั้งค่าคอลัมน์ del_status เป็น 'user'
            'del_dateTime': formattedDate, // วันที่และเวลาลบ
          });
        }
        // ลบข้อมูลจาก Firestore
        await _firestore.collection('user').doc(user.uid).delete();
        // ลบบัญชีผู้ใช้จาก Firebase Authentication
        await user.delete();

        // แสดงข้อความแจ้งเตือนว่าบัญชีถูกลบเรียบร้อยแล้ว
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("บัญชีของคุณถูกลบเรียบร้อยแล้ว",
                  style: GoogleFonts.itim())),
        );

        // ไปยังหน้า Login หลังจากลบบัญชี
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("แก้ไขโปรไฟล์", style: GoogleFonts.itim(fontSize: 26)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: "ชื่อผู้ใช้",
                labelStyle: GoogleFonts.itim(),
              ),
            ),
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: "ชื่อจริง",
                labelStyle: GoogleFonts.itim(),
              ),
            ),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: "นามสกุล",
                labelStyle: GoogleFonts.itim(),
              ),
            ),
            TextFormField(
              controller: _genderController,
              decoration: InputDecoration(
                labelText: "เพศ",
                labelStyle: GoogleFonts.itim(),
              ),
            ),
            TextFormField(
              controller: _birthdateController,
              decoration: InputDecoration(
                labelText: "วันเกิด",
                labelStyle: GoogleFonts.itim(),
              ),
            ),
            TextFormField(
              controller: _aboutmeController,
              decoration: InputDecoration(
                labelText: "คำแนะนำตัวเอง",
                labelStyle: GoogleFonts.itim(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ButtonStyle(
                minimumSize: WidgetStateProperty.all(const Size(350, 50)),
                backgroundColor: WidgetStateProperty.all(Colors.green),
              ),
              child: Text(
                "บันทึก",
                style: GoogleFonts.itim(fontSize: 26, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _deleteUser,
              child: Text(
                "ลบบัญชี",
                style: GoogleFonts.itim(fontSize: 20, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
