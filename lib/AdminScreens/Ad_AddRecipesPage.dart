import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminAddRecipesPage extends StatefulWidget {
  const AdminAddRecipesPage({super.key});

  @override
  _AdminAddRecipesPageState createState() => _AdminAddRecipesPageState();
}

class _AdminAddRecipesPageState extends State<AdminAddRecipesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _methodController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  final List<Map<String, dynamic>> _ingredients = [];
  final String defaultImage =
      'https://media.istockphoto.com/id/1182393436/vector/fast-food-seamless-pattern-with-vector-line-icons-of-hamburger-pizza-hot-dog-beverage.jpg?s=612x612&w=0&k=20&c=jlj-n_CNsrd13tkHwC7MVo0cGUyyc8YP6wJQdCvMUGw=';

  final String _foodType = 'ของคาว'; // ค่าเริ่มต้นเป็น "คาว"
  String _selectedType = 'ของคาว'; // ค่าเริ่มต้นคือ 'คาว'/ รายการประเภทอาหาร

  @override
  void dispose() {
    _nameController.dispose();
    _methodController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<int> _getNextRecipeId() async {
    final snapshot = await _firestore.collection('recipes').get();
    return snapshot.docs.isEmpty ? 1 : (snapshot.docs.length + 1) + 1;
  }

  Future<void> _saveRecipe() async {
    try {
      final imageUrl =
          _imageController.text.isEmpty ? defaultImage : _imageController.text;
      final nextRecipeId = await _getNextRecipeId();

      // เพิ่มสูตรอาหารใหม่
      await _firestore.collection('recipes').add({
        'recipes_id': nextRecipeId,
        'name': _nameController.text,
        'method': _methodController.text,
        'image': imageUrl,
        'type': _foodType, // เพิ่มประเภทอาหาร
      });

      // เพิ่มวัตถุดิบที่เกี่ยวข้องกับสูตรอาหารใหม่
      for (var ingredient in _ingredients) {
        await _firestore.collection('ingredients').add({
          'recipes_id': nextRecipeId,
          'name': ingredient['name'],
          'quantity': ingredient['quantity'],
          'unit': ingredient['unit'],
        });
      }

      // แสดงข้อความยืนยันการบันทึก
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เพิ่มสูตรอาหารสำเร็จ!')),
      );

      // เคลียร์ข้อมูล TextField
      _nameController.clear();
      _methodController.clear();
      _imageController.clear();
      setState(() {
        _ingredients.clear(); // ลบวัตถุดิบทั้งหมด
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          'เพิ่มสูตรอาหาร',
          style: GoogleFonts.itim(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _imageController,
                style: GoogleFonts.itim(),
                decoration: InputDecoration(
                  labelText: 'ลิงก์รูปภาพ',
                  labelStyle: GoogleFonts.itim(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: _imageController.text.isEmpty
                    ? Image.network(defaultImage, fit: BoxFit.cover)
                    : Image.network(_imageController.text, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _nameController,
                      style: GoogleFonts.itim(),
                      decoration: InputDecoration(
                        labelText: 'ชื่อสูตรอาหาร',
                        labelStyle: GoogleFonts.itim(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedType,
                      items: ['ของคาว', 'ของหวาน'].map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: GoogleFonts.itim(),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedType = newValue!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'ประเภทอาหาร',
                        border: OutlineInputBorder(),
                      ),
                      hint: Text(
                        'ประเภทอาหาร',
                        style: GoogleFonts.itim(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'วัตถุดิบ',
                style:
                    GoogleFonts.itim(textStyle: const TextStyle(fontSize: 20)),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = _ingredients[index];
                  return Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: ingredient['name'],
                          style: GoogleFonts.itim(),
                          decoration: InputDecoration(
                            labelText: 'ชื่อวัตถุดิบ',
                            labelStyle: GoogleFonts.itim(),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              ingredient['name'] = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: ingredient['quantity'],
                          style: GoogleFonts.itim(),
                          decoration: InputDecoration(
                            labelText: 'จำนวน',
                            labelStyle: GoogleFonts.itim(),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              ingredient['quantity'] = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: ingredient['unit'],
                          style: GoogleFonts.itim(),
                          decoration: InputDecoration(
                            labelText: 'หน่วย',
                            labelStyle: GoogleFonts.itim(),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              ingredient['unit'] = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 64,
                      ),
                    ],
                  );
                },
              ),
              TextButton.icon(
                onPressed: () {
                  bool hasEmptyName = false;

                  // ตรวจสอบว่ามีชื่อวัตถุดิบที่ว่างอยู่ในรายการหรือไม่
                  for (var ingredient in _ingredients) {
                    if (ingredient['name'].isEmpty) {
                      hasEmptyName = true;
                      break;
                    }
                  }

                  if (hasEmptyName) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('กรุณากรอกชื่อวัตถุดิบ')),
                    );
                  } else {
                    setState(() {
                      _ingredients.add({
                        'id': UniqueKey().toString(),
                        'name': '',
                        'quantity': '',
                        'unit': '',
                      });
                    });
                  }
                },
                icon: const Icon(
                  Icons.add,
                  size: 18,
                  color: Colors.black,
                ),
                label: Text(
                  'เพิ่มวัตถุดิบ',
                  style: GoogleFonts.itim(fontSize: 18, color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _methodController,
                style: GoogleFonts.itim(),
                maxLines: null,
                decoration: InputDecoration(
                  labelText: 'วิธีทำ',
                  labelStyle: GoogleFonts.itim(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveRecipe,
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(const Size(350, 50)),
                  backgroundColor: WidgetStateProperty.all(Colors.orange),
                ),
                child: Text(
                  "บันทึก",
                  style: GoogleFonts.itim(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
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
