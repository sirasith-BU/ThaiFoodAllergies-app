import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
  final List<String> _removedItems = [];

  @override
  void initState() {
    super.initState();
    _loadAllergicData();
  }

  Future<void> _loadAllergicData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection("allergicFood")
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
    // ตรวจสอบว่ามีช่องที่ยังไม่ได้กรอกหรือไม่
    final hasEmptyField =
        _controllers.any((controller) => controller.text.trim().isEmpty);

    if (hasEmptyField) {
      // แสดงข้อความเตือนหากมีช่องว่าง
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "กรุณากรอกวัตถุดิบก่อนเพิ่มช่องใหม่",
            style: GoogleFonts.itim(),
          ),
        ),
      );
    } else {
      // เพิ่มช่องใหม่ถ้าทุกช่องมีข้อมูลครบ
      setState(() {
        _controllers.add(TextEditingController());
      });
    }
  }

  void _removeField(int index) {
    setState(() {
      // เพิ่มข้อมูลที่ถูกลบลงใน `_removedItems`
      _removedItems.add(_controllers[index].text.trim());
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
  }

  Future<void> _saveAllergies() async {
    final user = _auth.currentUser;
    if (user != null) {
      final nonEmptyIngredients = _controllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toSet();

      // ดึงรายการที่มีอยู่ใน Firestore
      final snapshot = await _firestore
          .collection("allergicFood")
          .where("user_id", isEqualTo: user.uid)
          .get();

      final existingDocs = snapshot.docs;

      // แยกข้อมูลใน Firestore เป็น Map เพื่อช่วยในการตรวจสอบ
      final existingAllergiesMap = {
        for (var doc in existingDocs) doc["allergic_ingr"]: doc.reference
      };

      // สร้าง batch สำหรับการอัปเดต
      final batch = _firestore.batch();

      // ตรวจสอบการอัปเดตหรือลบ
      for (var doc in existingDocs) {
        final ingr = doc["allergic_ingr"] as String;

        if (!nonEmptyIngredients.contains(ingr)) {
          // หากข้อมูลไม่อยู่ในรายการใหม่ ให้ลบ
          batch.delete(doc.reference);
        }
      }

      // ตรวจสอบการเพิ่มหรืออัปเดต
      for (var ingr in nonEmptyIngredients) {
        if (existingAllergiesMap.containsKey(ingr)) {
          // หากข้อมูลยังอยู่ใน Firestore แต่ไม่เปลี่ยนแปลง ข้าม
          continue;
        } else {
          // หากเป็นข้อมูลใหม่ ให้เพิ่ม
          final docRef = _firestore.collection("allergicFood").doc();
          final now = DateTime.now();
          final formattedDate =
              "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year + 543}";
          final formattedTime = DateFormat('HH:mm:ss').format(now);

          batch.set(docRef, {
            'user_id': user.uid,
            'allergic_ingr': ingr,
            'date': formattedDate,
            'time': formattedTime,
          });
        }
      }

      // Commit batch
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "บันทึกข้อมูลสำเร็จ",
            style: GoogleFonts.itim(),
          ),
        ),
      );

      // เคลียร์รายการที่ถูกลบ
      _removedItems.clear();

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      "วัตุดิบอาหารที่คุณแพ้",
                      style: GoogleFonts.itim(
                        textStyle: const TextStyle(
                          fontSize: 44,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "เช่น นม ไก่ ไข่",
                      style: GoogleFonts.itim(
                        textStyle: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
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
                          labelText: "วัตถุดิบอาหารที่แพ้",
                          labelStyle: GoogleFonts.itim(color: Colors.white),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: GoogleFonts.itim(
                          fontSize: 26,
                          color: Colors.white,
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: ElevatedButton(
                      onPressed: _addNewField,
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.lightGreen),
                        minimumSize:
                            WidgetStateProperty.all(const Size(150, 50)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            "เพิ่ม",
                            style: GoogleFonts.itim(
                                fontSize: 24, color: Colors.white),
                          ),
                        ],
                      )),
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
      ),
    );
  }
}
