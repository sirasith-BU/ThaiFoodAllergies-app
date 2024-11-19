import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'RecipesDetailPage.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> recipesWithScores = []; // รายการที่จะแสดง

  @override
  void initState() {
    super.initState();
    _loadFavoritesWithScores(); // ใช้ฟังก์ชันที่ปรับปรุงแล้ว
  }

  Future<void> _loadFavoritesWithScores() async {
    recipesWithScores.clear();
    final user = _auth.currentUser;
    if (user == null) return; // หากไม่ได้ login ให้หยุดการทำงาน

    final favoriteCollection = _firestore.collection('favorite');
    final favoriteSnapshot = await favoriteCollection
        .where('user_id', isEqualTo: user.uid) // ดึงรายการโปรดของผู้ใช้
        .get();

    // ลูปผ่านรายการโปรดทั้งหมด
    for (var favoriteDoc in favoriteSnapshot.docs) {
      final favoriteData = favoriteDoc.data();
      final recipeId = favoriteData['recipes_id']; // ดึง recipes_id

      // ดึงข้อมูลจาก recipes collection โดยใช้ recipes_id
      final recipeSnapshot = await _firestore
          .collection('recipes')
          .where('recipes_id', isEqualTo: recipeId)
          .get();

      final recipeData = recipeSnapshot.docs.isNotEmpty
          ? recipeSnapshot.docs.first.data()
          : null;

      if (recipeData != null) {
        // ดึงข้อมูลจาก recipeRating collection โดยใช้ recipes_id
        final recipeRatingSnapshot = await _firestore
            .collection('recipeRating')
            .where('recipes_id', isEqualTo: recipeId)
            .get();

        double totalScore = 0;
        int ratingCount = 0;

        // ลูปผ่านแต่ละ recipeRating
        for (var recipeRatingDoc in recipeRatingSnapshot.docs) {
          final askRatingId = recipeRatingDoc['askRating_id'];

          // ดึงข้อมูลจาก askRating โดยใช้ askRatingId
          final askRatingSnapshot =
              await _firestore.collection('askRating').doc(askRatingId).get();

          if (askRatingSnapshot.exists) {
            final avgScore = askRatingSnapshot.data()?['avgScore'] ?? 0.0;
            totalScore += avgScore;
            ratingCount++;
          }
        }

        // คำนวณคะแนนเฉลี่ย
        final averageScore = ratingCount > 0 ? totalScore / ratingCount : 0.0;

        // เพิ่มข้อมูลลงใน recipesWithScores
        setState(() {
          recipesWithScores.add({
            'recipes_id': recipeId,
            'name': recipeData['name'] ?? 'ไม่พบชื่อ',
            'image':
                "https://media.istockphoto.com/id/1182393436/vector/fast-food-seamless-pattern-with-vector-line-icons-of-hamburger-pizza-hot-dog-beverage.jpg?s=612x612&w=0&k=20&c=jlj-n_CNsrd13tkHwC7MVo0cGUyyc8YP6wJQdCvMUGw=", // Default image if not available
            'avgScore': averageScore,
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text('รายการโปรด',
              style: GoogleFonts.itim(
                  textStyle:
                      const TextStyle(color: Colors.white, fontSize: 26))),
        ),
        backgroundColor: Colors.green,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.favorite, color: Colors.white),
          ),
        ],
      ),
      body: recipesWithScores.isEmpty
          ? const Center(child: Text('ไม่มีรายการโปรด'))
          : ListView.builder(
              itemCount: recipesWithScores.length,
              itemBuilder: (context, index) {
                final item = recipesWithScores[index];
                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 6, left: 6, bottom: 6, right: 0),
                      child: ListTile(
                        leading: Image.network(
                          item['image']!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          item['name']!,
                          style: GoogleFonts.itim(fontSize: 23),
                        ),
                        subtitle: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.yellow,
                              size: 24,
                            ),
                            Text(
                              item['avgScore'].toStringAsFixed(1),
                              style: GoogleFonts.itim(fontSize: 20),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.favorite,
                            size: 30,
                          ),
                          color: Colors.red,
                          onPressed: () {
                            setState(() {
                              recipesWithScores.removeAt(
                                  index); // Remove item from local list
                            });
                            _removeFromFavorites(
                                item['recipes_id']); // Remove from Firestore
                          },
                        ),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipesDetailPage(
                                recipesId: item['recipes_id'],
                                name: item['name'],
                                imageUrl: item['image'],
                              ),
                            ),
                          );
                          if (result == true) {
                            await _loadFavoritesWithScores(); // โหลดใหม่อีกครั้ง
                            setState(() {}); // รีเฟรช UI
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _removeFromFavorites(int recipeId) async {
    await _firestore
        .collection('favorite')
        .where('recipes_id',
            isEqualTo: recipeId) // ใช้เงื่อนไขค้นหา 'recipes_id'
        .get()
        .then((snapshot) async {
      for (var doc in snapshot.docs) {
        // ลบเอกสารที่พบ
        await _firestore.collection('favorite').doc(doc.id).delete();
      }
    });
  }
}
