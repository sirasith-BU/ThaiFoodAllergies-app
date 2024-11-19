import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/firebase_auth_services.dart';

class EditAllergiesPage extends StatefulWidget {
  const EditAllergiesPage({super.key});

  @override
  State<EditAllergiesPage> createState() => _EditAllergiesPageState();
}

class _EditAllergiesPageState extends State<EditAllergiesPage> {
  final List<TextEditingController> _controllers = [];
  final _auth = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadAllergicData();
  }

  Future<void> _loadAllergicData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection("allergic_food")
          .where("user_id", isEqualTo: user.uid)
          .get();
      for (var doc in snapshot.docs) {
        final controller = TextEditingController(text: doc["allergic_ingr"]);
        _controllers.add(controller);
      }
      if (_controllers.isEmpty) {
        _addNewField(); // เพิ่มช่องแรกถ้ายังไม่มีข้อมูล
      }
      setState(() {});
    }
  }

  void _addNewField() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeField(int index) {
    setState(() {
      _controllers[index].dispose(); // ลบ controller ออกจากหน่วยความจำ
      _controllers.removeAt(index);
    });
  }

  Future<void> _saveAllergies() async {
    final user = _auth.currentUser;
    if (user != null) {
      final nonEmptyIngredients = _controllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      // ลบข้อมูลเก่าทั้งหมดใน allergic_food
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection("allergic_food")
          .where("user_id", isEqualTo: user.uid)
          .get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      // เพิ่มข้อมูลใหม่ที่ไม่ว่าง
      for (var ingr in nonEmptyIngredients) {
        final docRef = _firestore.collection("allergic_food").doc();
        batch.set(docRef, {
          'user_id': user.uid,
          'allergic_ingr': ingr,
        });
      }
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("บันทึกข้อมูลอาหารที่แพ้เสร็จสิ้น",
              style: GoogleFonts.itim()),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.green,
      appBar: AppBar(
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "อาหารที่คุณแพ้",
                style: GoogleFonts.itim(
                  textStyle: const TextStyle(
                    fontSize: 60,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ..._controllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: "อาหารที่แพ้ เช่น นม",
                        labelStyle: GoogleFonts.itim(color: Colors.white),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.red),
                    onPressed: () => _removeField(index),
                  ),
                ],
              );
            }),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _addNewField,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.lightGreen),
                  minimumSize: WidgetStateProperty.all(const Size(150, 50)),
                ),
                child: Text(
                  "เพิ่ม",
                  style: GoogleFonts.itim(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveAllergies,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.lightGreen),
                  minimumSize: WidgetStateProperty.all(const Size(150, 50)),
                ),
                child: Text(
                  "บันทึก",
                  style: GoogleFonts.itim(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
