import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodallergies_app/AdminScreens/Ad_MainPage.dart';
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
  final String _foodType = 'ของคาว'; // ค่าเริ่มต้นเป็น "คาว"
  String _selectedType = 'ของคาว'; // ค่าเริ่มต้นคือ 'คาว'/ รายการประเภทอาหาร

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

        // เพิ่มการโหลดข้อมูล type
        _selectedType =
            recipeData['type'] ?? 'คาว'; // สมมติว่า default คือ 'คาว'
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
      final recipeName = _nameController.text.trim();
      final method = _methodController.text.trim();

      // ตรวจสอบชื่อสูตรอาหาร
      if (recipeName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณากรอกชื่อสูตรอาหาร')),
        );
        return;
      }

      // ตรวจสอบว่ามีวัตถุดิบอย่างน้อย 1 อย่างที่ชื่อไม่ว่างเปล่า
      if (_ingredients.isEmpty ||
          _ingredients.any((ingredient) => ingredient['name'].trim().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('กรุณาเพิ่มวัตถุดิบที่มีชื่ออย่างน้อย 1 รายการ')),
        );
        return;
      }

      // ตรวจสอบว่ามีวิธีทำ
      if (method.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณากรอกวิธีทำ')),
        );
        return;
      }

      final imageUrl =
          _imageController.text.isEmpty ? defaultImage : _imageController.text;

      // ตรวจสอบชื่อซ้ำก่อนบันทึก
      final nameQuerySnapshot = await _firestore
          .collection('recipes')
          .where('name', isEqualTo: recipeName)
          .get();

      if (nameQuerySnapshot.docs.isNotEmpty) {
        final existingDoc = nameQuerySnapshot.docs.first;
        final existingRecipeId = existingDoc['recipes_id'];

        if (existingRecipeId != widget.recipesId) {
          // ชื่อซ้ำและไม่ใช่สูตรที่กำลังแก้ไข แสดง Dialog แจ้งเตือน
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('ชื่อซ้ำ'),
              content: Text(
                'มีชื่อ "$recipeName" อยู่ในระบบแล้ว กรุณาเปลี่ยนชื่อหรือลองเพิ่มคำอธิบายเพิ่มเติม',
                style: GoogleFonts.itim(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ตกลง'),
                ),
              ],
            ),
          );
          return; // หยุดการทำงานของฟังก์ชัน
        }
      }

      // ลบวัตถุดิบที่ต้องการลบ
      for (var ingredient in _ingredientsToDelete) {
        await _firestore
            .collection('ingredients')
            .doc(ingredient['id'])
            .delete();
      }

      // อัปเดตหรือสร้างข้อมูลใน recipes
      final querySnapshot = await _firestore
          .collection('recipes')
          .where('recipes_id', isEqualTo: widget.recipesId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        await _firestore.collection('recipes').doc(docId).update({
          'name': recipeName,
          'method': method,
          'image': imageUrl,
          'type': _foodType,
        });
      } else {
        await _firestore.collection('recipes').add({
          'recipes_id': widget.recipesId,
          'name': recipeName,
          'method': method,
          'image': imageUrl,
          'type': _foodType,
        });
      }

      // อัปเดตหรือเพิ่มข้อมูลวัตถุดิบ
      for (var ingredient in _ingredients) {
        final ingredientDoc = await _firestore
            .collection('ingredients')
            .doc(ingredient['id'])
            .get();

        if (ingredientDoc.exists) {
          await _firestore
              .collection('ingredients')
              .doc(ingredient['id'])
              .update({
            'name': ingredient['name'],
            'quantity': ingredient['quantity'],
            'unit': ingredient['unit'],
          });
        } else {
          await _firestore.collection('ingredients').add({
            'recipes_id': widget.recipesId,
            'name': ingredient['name'],
            'quantity': ingredient['quantity'],
            'unit': ingredient['unit'],
          });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('แก้ไขสูตรอาหารสำเร็จ!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
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

  Future<void> _deleteRecipes() async {
    // แสดง Dialog ยืนยันการลบ
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text(
          'คุณต้องการลบสูตรอาหารนี้และวัตถุดิบที่เกี่ยวข้องทั้งหมดหรือไม่?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // ยกเลิก
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // ตกลง
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );

    // หากผู้ใช้ยืนยันการลบ
    if (shouldDelete == true) {
      try {
        // ลบเอกสารจาก Collection recipes
        final recipeQuerySnapshot = await _firestore
            .collection('recipes')
            .where('recipes_id', isEqualTo: widget.recipesId)
            .get();

        for (var recipeDoc in recipeQuerySnapshot.docs) {
          await _firestore.collection('recipes').doc(recipeDoc.id).delete();
        }

        // ลบเอกสารจาก Collection ingredients
        final ingredientsQuerySnapshot = await _firestore
            .collection('ingredients')
            .where('recipes_id', isEqualTo: widget.recipesId)
            .get();

        for (var ingredientDoc in ingredientsQuerySnapshot.docs) {
          await _firestore
              .collection('ingredients')
              .doc(ingredientDoc.id)
              .delete();
        }

        // แสดงข้อความยืนยันการลบสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบสูตรอาหารสำเร็จ!')),
        );

        // ปิดหน้าหรือย้อนกลับ
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const AdminMainPage()));
      } catch (e) {
        // แจ้งเตือนเมื่อเกิดข้อผิดพลาด
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'แก้ไขสูตรอาหาร',
          style: GoogleFonts.itim(),
        ),
        backgroundColor: Colors.white,
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
                        labelText: 'ประเภทอาหาร', // ข้อความกำกับที่จะแสดง
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
                          initialValue: ingredient['quantity']
                              .toString(), // แปลงเป็น String
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
              const SizedBox(
                height: 10,
              ),
              TextButton(
                  onPressed: _deleteRecipes,
                  child: Text(
                    "ลบสูตรอาหาร",
                    style: GoogleFonts.itim(fontSize: 20, color: Colors.red),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
