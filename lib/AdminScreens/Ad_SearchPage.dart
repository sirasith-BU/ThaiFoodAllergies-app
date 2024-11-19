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
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("recipes").get();
    setState(() {
      searchResults = snapshot.docs
          .map((doc) => {
                "id": doc.id,
                "name": doc["name"],
                "image": doc["image"], // รูปภาพเมนูอาหาร
              })
          .toList();
    });
  }

  void searchRecipes() async {
    if (searchQuery.isNotEmpty) {
      // หากมีการพิมพ์คำค้นหา
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("recipes")
          .where("name", isGreaterThanOrEqualTo: searchQuery)
          .where("name", isLessThanOrEqualTo: '$searchQuery\uf8ff')
          .get();

      setState(() {
        searchResults = snapshot.docs
            .map((doc) => {
                  "id": doc.id,
                  "name": doc["name"],
                  "image": doc["image"], // รูปภาพเมนูอาหาร
                })
            .toList();
      });
    } else {
      // หากไม่กรอกคำค้นหาก็โหลดเมนูทั้งหมด
      fetchAllRecipes();
    }
  }

  Widget _buildImageSliderItem(String name, int recipeId) {
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
                imageUrl:
                    "https://media.istockphoto.com/id/1182393436/vector/fast-food-seamless-pattern-with-vector-line-icons-of-hamburger-pizza-hot-dog-beverage.jpg?s=612x612&w=0&k=20&c=jlj-n_CNsrd13tkHwC7MVo0cGUyyc8YP6wJQdCvMUGw=", // ส่ง URL ของรูปภาพไปยัง RecipesDetailPage
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
                  Image.network(
                    "https://media.istockphoto.com/id/1182393436/vector/fast-food-seamless-pattern-with-vector-line-icons-of-hamburger-pizza-hot-dog-beverage.jpg?s=612x612&w=0&k=20&c=jlj-n_CNsrd13tkHwC7MVo0cGUyyc8YP6wJQdCvMUGw=",
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
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   title: Text(
      //     'ค้นหาเมนูอาหาร',
      //     style: GoogleFonts.itim(fontSize: 26),
      //   ),
      // ),
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
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
                          fetchAllRecipes(); // ดึงข้อมูลทั้งหมดเมื่อเลือกทั้งหมด
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
                          )),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedFilter = 'ของคาว';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedFilter == 'ของคาว'
                              ? Colors.orange
                              : Colors.grey,
                          minimumSize: const Size(0, 50), // กำหนดความสูงของปุ่ม
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
                          )),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedFilter = 'ของหวาน';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedFilter == 'ของหวาน'
                              ? Colors.orange
                              : Colors.grey,
                          minimumSize: const Size(0, 50), // กำหนดความสูงของปุ่ม
                        ),
                        child: Text(
                          'ของหวาน',
                          style: GoogleFonts.itim(
                              textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: selectedFilter == 'ของหวาน'
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 18,
                          )),
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
              stream: searchQuery.isNotEmpty
                  ? FirebaseFirestore.instance
                      .collection("recipes")
                      .where("name", isGreaterThanOrEqualTo: searchQuery)
                      .where("name", isLessThanOrEqualTo: '$searchQuery\uf8ff')
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection("recipes")
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final recipeDocument = snapshot.data!.docs[index];
                    final name = recipeDocument["name"];
                    final recId = recipeDocument["recipes_id"];

                    return _buildImageSliderItem(name, recId);
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
