import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class EditRecipesPage extends StatefulWidget {
  final int recipesId;

  const EditRecipesPage({super.key, required this.recipesId});

  @override
  _EditRecipesPageState createState() => _EditRecipesPageState();
}

class _EditRecipesPageState extends State<EditRecipesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _methodController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  List<Map<String, dynamic>> _ingredients = [];
  final List<Map<String, dynamic>> _ingredientsToDelete =
      []; // เก็บวัตถุดิบที่ต้องการลบ
  final String defaultImage =
      'https://media.istockphoto.com/id/1182393436/vector/fast-food-seamless-pattern-with-vector-line-icons-of-hamburger-pizza-hot-dog-beverage.jpg?s=612x612&w=0&k=20&c=jlj-n_CNsrd13tkHwC7MVo0cGUyyc8YP6wJQdCvMUGw=';

  @override
  void initState() {
    super.initState();
    _loadRecipeData();
  }

  Future<void> _loadRecipeData() async {
    try {
      final recipeSnapshot = await _firestore
          .collection('recipes')
          .where('recipes_id', isEqualTo: widget.recipesId)
          .get();

      if (recipeSnapshot.docs.isNotEmpty) {
        final recipeData = recipeSnapshot.docs.first.data();
        _nameController.text = recipeData['name'] ?? '';
        _methodController.text = recipeData['method'] ?? '';
        _imageController.text = recipeData['image'] ?? '';
      }

      final ingredientsSnapshot = await _firestore
          .collection('ingredients')
          .where('recipes_id', isEqualTo: widget.recipesId)
          .get();

      setState(() {
        _ingredients = ingredientsSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? '',
            'quantity': data['quantity'] ?? '',
            'unit': data['unit'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<void> _saveRecipe() async {
    try {
      // ตรวจสอบว่ารูปภาพมีค่าหรือไม่ หากไม่มีให้ใช้ defaultImage
      final imageUrl =
          _imageController.text.isEmpty ? defaultImage : _imageController.text;

      // ลบวัตถุดิบที่ถูกเลือกให้ลบ
      for (var ingredient in _ingredientsToDelete) {
        await _firestore
            .collection('ingredients')
            .doc(ingredient['id']) // ใช้ ID ของวัตถุดิบที่ต้องการลบ
            .delete();
      }

      // อัปเดต recipes
      final querySnapshot = await _firestore
          .collection('recipes')
          .where('recipes_id', isEqualTo: widget.recipesId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // ดึง documentId ของเอกสารที่พบ
        final docId = querySnapshot.docs.first.id;
        // อัปเดตข้อมูล
        await _firestore.collection('recipes').doc(docId).update({
          'name': _nameController.text,
          'method': _methodController.text,
          'image': imageUrl,
        });
      }

      // อัปเดตหรือเพิ่ม ingredients
      for (var ingredient in _ingredients) {
        // ใช้ doc() ค้นหาจาก ingredient['id']
        final ingredientDoc = await _firestore
            .collection('ingredients')
            .doc(ingredient['id']) // ใช้ ID เพื่อค้นหา
            .get();

        if (ingredientDoc.exists) {
          // หากมีข้อมูลใน Firestore ให้ทำการอัปเดตชื่อและข้อมูลอื่นๆ
          await _firestore
              .collection('ingredients')
              .doc(ingredient['id'])
              .update({
            'name': ingredient['name'],
            'quantity': ingredient['quantity'],
            'unit': ingredient['unit'],
          });
        } else {
          // หากไม่มีข้อมูลให้เพิ่มใหม่
          await _firestore.collection('ingredients').add({
            'recipes_id': widget.recipesId,
            'name': ingredient['name'],
            'quantity': ingredient['quantity'],
            'unit': ingredient['unit'],
          });
        }
      }

      // แสดงข้อความยืนยันการบันทึก
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('แก้ไขสูตรอาหารสำเร็จ!')),
      );
      Navigator.pop(context, true); // กลับไปหน้าก่อนหน้า
    } catch (e) {
      // แสดงข้อผิดพลาดหากเกิดขึ้น
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<void> _deleteIngredient(String ingredientId, int index) async {
    bool shouldDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'ยืนยันการลบ',
            style: GoogleFonts.itim(),
          ),
          content: Text(
            'คุณต้องการลบวัตถุดิบนี้ใช่ไหม?',
            style: GoogleFonts.itim(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'ยกเลิก',
                style: GoogleFonts.itim(),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                'ยืนยัน',
                style: GoogleFonts.itim(),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete) {
      setState(() {
        _ingredientsToDelete.add(_ingredients[index]); // เพิ่มวัตถุดิบที่จะลบ
        _ingredients.removeAt(index); // ลบจาก UI
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ลบวัตถุดิบเรียบร้อย!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'แก้ไขสูตรอาหาร',
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
              TextFormField(
                controller: _nameController,
                style: GoogleFonts.itim(),
                decoration: InputDecoration(
                  labelText: 'ชื่อสูตรอาหาร',
                  labelStyle: GoogleFonts.itim(),
                  border: const OutlineInputBorder(),
                ),
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
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteIngredient(ingredient['id'], index);
                        },
                      )
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
