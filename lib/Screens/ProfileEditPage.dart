import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                labelText: "คำอธิบาย",
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
          ],
        ),
      ),
    );
  }
}
