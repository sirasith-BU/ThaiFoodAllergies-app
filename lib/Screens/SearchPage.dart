import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodallergies_app/Screens/RecipesDetailPage.dart';
import 'package:foodallergies_app/auth/firebase_auth_services.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String selectedFilter = 'ทั้งหมด';
  String searchQuery = '';
  List<Map<String, dynamic>> searchResults = [];
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    fetchAllRecipes();
  }

  Future<List<String>> fetchUserAllergies(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('allergic_food')
        .where('user_id', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => doc['allergic_ingr'].toString()).toList();
  }

  void fetchAllRecipes() async {
    Query query = FirebaseFirestore.instance.collection("recipes");
    QuerySnapshot snapshot = await query.get();
    setState(() {
      searchResults = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?; // Cast to a Map
        return {
          "id": data?["recipes_id"] ?? "", // Use null-aware access
          "name": data?["name"] ?? "Unknown Name",
          "image": data?["image"] ??
              "https://media.istockphoto.com/id/1182393436/vector/fast-food-seamless-pattern-with-vector-line-icons-of-hamburger-pizza-hot-dog-beverage.jpg?s=612x612&w=0&k=20&c=jlj-n_CNsrd13tkHwC7MVo0cGUyyc8YP6wJQdCvMUGw=",
        };
      }).toList();
    });
  }

  void searchRecipes() async {
    Query query = FirebaseFirestore.instance.collection("recipes");

    if (searchQuery.isNotEmpty) {
      query = query
          .where("name", isGreaterThanOrEqualTo: searchQuery)
          .where("name", isLessThanOrEqualTo: '$searchQuery\uf8ff');
    }

    if (selectedFilter == 'ของคาว') {
      query = query.where("type", isEqualTo: "คาว");
    } else if (selectedFilter == 'ของหวาน') {
      query = query.where("type", isEqualTo: "หวาน");
    }

    QuerySnapshot snapshot = await query.get();
    setState(() {
      searchResults = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?; // Cast to a Map
        return {
          "id": data?["recipes_id"] ?? "", // Use null-aware access
          "name": data?["name"] ?? "Unknown Name",
          "image": data?["image"] ??
              "https://media.istockphoto.com/id/1182393436/vector/fast-food-seamless-pattern-with-vector-line-icons-of-hamburger-pizza-hot-dog-beverage.jpg?s=612x612&w=0&k=20&c=jlj-n_CNsrd13tkHwC7MVo0cGUyyc8YP6wJQdCvMUGw=",
        };
      }).toList();
    });
  }

  Widget _buildImageSliderItem(String name, int recipeId, String imageUrl) {
    imageUrl = imageUrl.isNotEmpty
        ? imageUrl
        : 'https://example.com/default_image.png';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipesDetailPage(
                recipesId: recipeId,
                name: name,
                imageUrl: imageUrl, // ใช้ URL จาก Firestore
              ),
            ),
          );
        },
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.network(
                              'https://media.istockphoto.com/id/1182393436/vector/fast-food-seamless-pattern-with-vector-line-icons-of-hamburger-pizza-hot-dog-beverage.jpg?s=612x612&w=0&k=20&c=jlj-n_CNsrd13tkHwC7MVo0cGUyyc8YP6wJQdCvMUGw=',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            );
                          },
                        )
                      : Image.network(
                          'https://media.istockphoto.com/id/1182393436/vector/fast-food-seamless-pattern-with-vector-line-icons-of-hamburger-pizza-hot-dog-beverage.jpg?s=612x612&w=0&k=20&c=jlj-n_CNsrd13tkHwC7MVo0cGUyyc8YP6wJQdCvMUGw=',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        name,
                        style: GoogleFonts.itim(
                          textStyle: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchFilteredRecipes() async {
    Query query = FirebaseFirestore.instance.collection("recipes");

    // Apply search query filter
    if (searchQuery.isNotEmpty) {
      query = query
          .where("name", isGreaterThanOrEqualTo: searchQuery)
          .where("name", isLessThanOrEqualTo: '$searchQuery\uf8ff');
    }

    // Apply selectedFilter
    if (selectedFilter == 'ของคาว') {
      query = query.where("type", isEqualTo: "ของคาว");
    } else if (selectedFilter == 'ของหวาน') {
      query = query.where("type", isEqualTo: "ของหวาน");
    }

    // Fetch recipes and ingredients
    final recipesSnapshot = await query.get();
    final ingredientsSnapshot =
        await FirebaseFirestore.instance.collection("ingredients").get();

    // Fetch allergic ingredients of the current user
    final allergicSnapshot = await FirebaseFirestore.instance
        .collection("allergic_food")
        .where("user_id", isEqualTo: _auth.currentUser?.uid)
        .get();

    final allergicIngredients =
        allergicSnapshot.docs.map((doc) => doc["allergic_ingr"]).toSet();

    // Log รายการส่วนผสมที่ผู้ใช้แพ้
    debugPrint("Allergic Ingredients: $allergicIngredients");

    // แยกสูตรอาหารที่มีส่วนผสมหรือชื่อที่ผู้ใช้แพ้ออกมา
    final allergicRecipes = <Map<String, dynamic>>[];
    final filteredRecipes = recipesSnapshot.docs.where((recipeDoc) {
      final data = recipeDoc.data() as Map<String, dynamic>;
      final recipeName = data["name"] ?? "";
      final recipeId = data["recipes_id"];
      final recipeIngredients = ingredientsSnapshot.docs
          .where((ingrDoc) => ingrDoc["recipes_id"] == recipeId)
          .map((ingrDoc) => ingrDoc["name"])
          .toSet();

      // Log รายการส่วนผสมของแต่ละสูตรอาหาร
      // debugPrint("Recipe Name: $recipeName, Ingredients: $recipeIngredients");

      // ถ้าสูตรอาหารมีชื่อหรือส่วนผสมที่ผู้ใช้แพ้ ให้ log ออกมา
      final containsAllergicName = allergicIngredients.any((allergen) =>
          recipeName.contains(allergen)); // ชื่อสูตรอาหารที่มีคำที่ผู้ใช้แพ้

      if (containsAllergicName ||
          recipeIngredients.intersection(allergicIngredients).isNotEmpty) {
        // debugPrint("Allergic Recipe Found: $recipeName");
        allergicRecipes.add({
          "id": recipeId,
          "name": recipeName,
          "ingredients": recipeIngredients,
        });
        return false; // ไม่รวมในผลลัพธ์
      }

      // ถ้าไม่มีชื่อหรือส่วนผสมที่ผู้ใช้แพ้ ให้รวมไว้ในผลลัพธ์
      return true;
    }).map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        "id": data["recipes_id"],
        "name": data["name"],
        "image": data["image"],
      };
    }).toList();

    // Log สูตรอาหารที่มีส่วนผสมหรือชื่อที่ผู้ใช้แพ้
    debugPrint("Allergic Recipes: $allergicRecipes");

    return filteredRecipes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'ค้นหาสูตรอาหาร',
          style: GoogleFonts.itim(fontSize: 26),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                    searchRecipes(); // เรียกใช้ฟังก์ชันค้นหาหลังจากกรอกคำค้น
                  },
                  decoration: InputDecoration(
                    labelText: 'กินอะไรดี...',
                    labelStyle: GoogleFonts.itim(),
                    suffixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedFilter = 'ทั้งหมด';
                          });
                          fetchAllRecipes(); // ดึงข้อมูลทั้งหมดเมื่อเลือก "ทั้งหมด"
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedFilter == 'ทั้งหมด'
                              ? Colors.green
                              : Colors.grey,
                          minimumSize: const Size(0, 50), // กำหนดความสูงของปุ่ม
                        ),
                        child: Text(
                          'ทั้งหมด',
                          style: GoogleFonts.itim(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: selectedFilter == 'ทั้งหมด'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedFilter = 'ของคาว';
                          });
                          fetchAllRecipes(); // ดึงข้อมูลประเภท "คาว"
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedFilter == 'ของคาว'
                              ? Colors.green
                              : Colors.grey,
                          minimumSize: const Size(0, 50),
                        ),
                        child: Text(
                          'ของคาว',
                          style: GoogleFonts.itim(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: selectedFilter == 'ของคาว'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedFilter = 'ของหวาน';
                          });
                          fetchAllRecipes(); // ดึงข้อมูลประเภท "หวาน"
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedFilter == 'ของหวาน'
                              ? Colors.green
                              : Colors.grey,
                          minimumSize: const Size(0, 50),
                        ),
                        child: Text(
                          'ของหวาน',
                          style: GoogleFonts.itim(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: selectedFilter == 'ของหวาน'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 19,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchFilteredRecipes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'เกิดข้อผิดพลาด: ${snapshot.error}',
                        style: GoogleFonts.itim(fontSize: 24),
                      ),
                    ),
                  );
                }
                final recipes = snapshot.data ?? [];
                if (recipes.isEmpty) {
                  return Center(
                    child: Text(
                      'ไม่พบสูตรอาหาร',
                      style: GoogleFonts.itim(fontSize: 24),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return _buildImageSliderItem(
                      recipe["name"] ?? "ไม่มีชื่อ",
                      recipe["id"] ?? -1,
                      recipe["image"] ??
                          "https://media.istockphoto.com/id/1182393436/vector/fast-food-seamless-pattern-with-vector-line-icons-of-hamburger-pizza-hot-dog-beverage.jpg?s=612x612&w=0&k=20&c=jlj-n_CNsrd13tkHwC7MVo0cGUyyc8YP6wJQdCvMUGw=",
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
