import 'package:flutter/material.dart';
import 'package:foodallergies_app/Screens/MainPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodallergies_app/auth/firebase_auth_services.dart';

class FirstAllergiesPage extends StatefulWidget {
  const FirstAllergiesPage(BuildContext context, {super.key});

  @override
  State<FirstAllergiesPage> createState() => _FirstAllergiesPageState();
}

class _FirstAllergiesPageState extends State<FirstAllergiesPage> {
  final _auth = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _allergic_ingr = TextEditingController();

  Future<void> _saveAllergy() async {
    final user = _auth.currentUser;
    if (user != null && _allergic_ingr.text.isNotEmpty) {
      try {
        await _firestore.collection("allergic_food").add({
          'user_id': user.uid,
          'allergic_ingr': _allergic_ingr.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("บันทึกข้อมูลสำเร็จ")),
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const MainPage()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("เกิดข้อผิดพลาดในการบันทึกข้อมูล")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const MainPage()));
            },
            child: const Text(
              'Skip',
              style: TextStyle(color: Colors.white, fontSize: 26),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "กรุณากรอกวัตถุดิบอาหารที่แพ้",
                style: GoogleFonts.itim(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 42,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "เช่น กุ้ง นม ไข่",
                style: GoogleFonts.itim(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _allergic_ingr,
                decoration: InputDecoration(
                    labelText: "วัตถุดิบอาหารที่แพ้ อย่างน้อย 1 อย่าง",
                    labelStyle: GoogleFonts.itim(
                        textStyle:
                            const TextStyle(color: Colors.white, fontSize: 20)),
                    enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white))),
                style: GoogleFonts.itim(color: Colors.white, fontSize: 26),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveAllergy,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.lightGreen),
                  minimumSize: WidgetStateProperty.all(const Size(150, 50)),
                ),
                child: Text(
                  "บันทึก",
                  style: GoogleFonts.itim(
                      textStyle:
                          const TextStyle(color: Colors.white, fontSize: 24)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
