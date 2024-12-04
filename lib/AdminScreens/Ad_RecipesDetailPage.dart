import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Ad_EditRecipesPage.dart';

class AdminRecipesDetailPage extends StatefulWidget {
  final int recipesId;
  final String name;
  final String imageUrl;

  const AdminRecipesDetailPage({
    super.key,
    required this.recipesId,
    required this.name,
    required this.imageUrl,
  });

  @override
  _AdminRecipesDetailPageState createState() => _AdminRecipesDetailPageState();
}

class _AdminRecipesDetailPageState extends State<AdminRecipesDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? recipeData;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> ingredients = [];

  @override
  void initState() {
    super.initState();
    _loadData(); // โหลดข้อมูลครั้งแรก
  }

  Future<void> _loadData() async {
    // โหลดข้อมูลสูตรอาหาร
    final recipeSnapshot = await _firestore
        .collection('recipes')
        .where('recipes_id', isEqualTo: widget.recipesId)
        .get();

    if (recipeSnapshot.docs.isNotEmpty) {
      recipeData = recipeSnapshot.docs.first.data();
    } else {
      recipeData = {
        'method': 'ไม่มีข้อมูลวิธีทำ',
        'image': widget.imageUrl,
        'ingredients': 'ไม่มีข้อมูลวัตถุดิบ'
      };
    }

    // โหลดข้อมูลวัตถุดิบ
    final ingredientsSnapshot = await _firestore
        .collection('ingredients')
        .where('recipes_id', isEqualTo: widget.recipesId)
        .get();

    ingredients = ingredientsSnapshot.docs;

    setState(() {}); // กระตุ้นให้ UI อัปเดต
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // กลับไปหน้าก่อนหน้า
          },
        ),
      ),
      body: recipeData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      widget.imageUrl.isNotEmpty
                          ? Image.network(
                              widget.imageUrl,
                              width: double.infinity,
                              height: 250,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.network(
                                  'https://media.istockphoto.com/id/1182393436/vector/fast-food-seamless-pattern-with-vector-line-icons-of-hamburger-pizza-hot-dog-beverage.jpg?s=612x612&w=0&k=20&c=jlj-n_CNsrd13tkHwC7MVo0cGUyyc8YP6wJQdCvMUGw=',
                                  width: double.infinity,
                                  height: 250,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.network(
                              'https://media.istockphoto.com/id/1182393436/vector/fast-food-seamless-pattern-with-vector-line-icons-of-hamburger-pizza-hot-dog-beverage.jpg?s=612x612&w=0&k=20&c=jlj-n_CNsrd13tkHwC7MVo0cGUyyc8YP6wJQdCvMUGw=',
                              width: double.infinity,
                              height: 250,
                              fit: BoxFit.cover,
                            ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                          padding: const EdgeInsets.all(4),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  recipeData!['name'] ?? widget.name,
                                  style: GoogleFonts.itim(
                                    textStyle: const TextStyle(
                                      fontSize: 30,
                                      color: Colors.white,
                                      // fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditRecipesPage(
                                          recipesId: widget.recipesId,
                                        ),
                                      ),
                                    );

                                    // หากแก้ไขสำเร็จ ให้โหลดข้อมูลใหม่
                                    if (result == true) {
                                      await _loadData();
                                    }
                                  },
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.orange,
                                    size: 50,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'วัตถุดิบ',
                      style: GoogleFonts.itim(
                        textStyle: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ingredients.length,
                    itemBuilder: (context, index) {
                      final ingrName = ingredients[index]['name'];
                      final quantity = ingredients[index]['quantity'] ?? "";
                      final unit = ingredients[index]['unit'] ?? "";
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 6, top: 6, bottom: 6),
                        child: Text(
                          "- $ingrName $quantity $unit",
                          style: GoogleFonts.itim(fontSize: 18),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'วิธีทำ',
                      style: GoogleFonts.itim(
                        textStyle: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      recipeData!['method'] ?? 'ไม่มีข้อมูลวิธีทำ',
                      style: GoogleFonts.itim(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
