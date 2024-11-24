import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodallergies_app/AdminScreens/Ad_RecipesDetailPage.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminSearchPage extends StatefulWidget {
  const AdminSearchPage({super.key});

  @override
  State<AdminSearchPage> createState() => _AdminSearchPageState();
}

class _AdminSearchPageState extends State<AdminSearchPage> {
  String selectedFilter = 'ทั้งหมด';
  String searchQuery = '';
  List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();
    fetchAllRecipes();
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
      query = query.where("type", isEqualTo: selectedFilter);
    } else if (selectedFilter == 'ของหวาน') {
      query = query.where("type", isEqualTo: selectedFilter);
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
              builder: (context) => AdminRecipesDetailPage(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
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
                    labelText: 'ค้นหาสูตรอาหาร',
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
                              ? Colors.orange
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
                              ? Colors.orange
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
                              ? Colors.orange
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
            child: StreamBuilder<QuerySnapshot>(
              stream: () {
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

                return query.snapshots();
              }(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'ไม่พบข้อมูล',
                      style: GoogleFonts.itim(fontSize: 24),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final recipeDocument = snapshot.data!.docs[index];
                    final data = recipeDocument.data()
                        as Map<String, dynamic>?; // Safe cast
                    final name = data?["name"] ?? "Unknown Recipe";
                    final recId =
                        data?["recipes_id"] ?? -1; // Use a default value
                    final imageUrl = data?["image"] ??
                        "https://media.istockphoto.com/id/1182393436/vector/fast-food-seamless-pattern-with-vector-line-icons-of-hamburger-pizza-hot-dog-beverage.jpg?s=612x612&w=0&k=20&c=jlj-n_CNsrd13tkHwC7MVo0cGUyyc8YP6wJQdCvMUGw=";

                    return _buildImageSliderItem(name, recId, imageUrl);
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
