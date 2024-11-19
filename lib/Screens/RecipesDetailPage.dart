import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'RecipesRatingPage.dart';

class RecipesDetailPage extends StatefulWidget {
  final int recipesId;
  final String name;
  final String imageUrl;

  const RecipesDetailPage({
    super.key,
    required this.recipesId,
    required this.name,
    required this.imageUrl,
  });

  @override
  _RecipesDetailPageState createState() => _RecipesDetailPageState();
}

class _RecipesDetailPageState extends State<RecipesDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to continue")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true); // ส่งค่า true กลับไปที่หน้า Favorite
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  widget.imageUrl,
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
                            widget.name,
                            style: GoogleFonts.itim(
                              textStyle: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: _firestore
                                .collection('favorite')
                                .where('user_id', isEqualTo: userId)
                                .where('recipes_id',
                                    isEqualTo: widget.recipesId)
                                .limit(1)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              }
                              bool isFavorite = snapshot.data!.docs.isNotEmpty;

                              return GestureDetector(
                                onTap: () async {
                                  final favCollection =
                                      _firestore.collection('favorite');
                                  final favoriteDoc = await favCollection
                                      .where('user_id', isEqualTo: userId)
                                      .where('recipes_id',
                                          isEqualTo: widget.recipesId)
                                      .limit(1)
                                      .get();

                                  if (favoriteDoc.docs.isEmpty) {
                                    // เพิ่มสูตรลงใน Favorite
                                    await favCollection.add({
                                      'user_id': userId,
                                      'recipes_id': widget.recipesId,
                                      'date': DateFormat('dd-MM-yyyy')
                                          .format(DateTime.now()),
                                      'time': DateFormat('HH:mm:ss')
                                          .format(DateTime.now()),
                                    });
                                  } else {
                                    // ลบสูตรออกจาก Favorite
                                    await favCollection
                                        .doc(favoriteDoc.docs.first.id)
                                        .delete();
                                  }
                                },
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.white,
                                  size: 30,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('recipeRating')
                    .where('recipes_id', isEqualTo: widget.recipesId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final ratings = snapshot.data!.docs;
                  double totalScore = 0;

                  // สร้าง list ของ Future เพื่อดึงข้อมูลทั้งหมดก่อน
                  List<Future<void>> futureList = [];

                  for (var ratingDoc in ratings) {
                    final askRatingId = ratingDoc['askRating_id'];

                    // สำหรับแต่ละ askRatingId ให้เพิ่ม Future
                    Future<void> ratingFuture = _firestore
                        .collection('askRating')
                        .doc(askRatingId)
                        .get()
                        .then((askRatingSnapshot) {
                      if (askRatingSnapshot.exists) {
                        final askRating = askRatingSnapshot.data();
                        final tasteRating = askRating?['taste_rating'] ?? 0;
                        final difficultRating =
                            askRating?['difficult_rating'] ?? 0;
                        final presentRating = askRating?['present_rating'] ?? 0;

                        totalScore +=
                            (tasteRating + difficultRating + presentRating) / 3;
                      }
                    });

                    futureList.add(ratingFuture);
                  }

                  // รอให้ Future ทั้งหมดเสร็จสิ้น
                  return FutureBuilder(
                    future: Future.wait(futureList),
                    builder: (context, futureSnapshot) {
                      if (futureSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // แสดงคะแนน
                      return Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 44,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            totalScore == 0
                                ? '0.0'
                                : totalScore.toStringAsFixed(1),
                            style: GoogleFonts.itim(
                              textStyle: const TextStyle(
                                fontSize: 24,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'วัตถุดิบ',
                style: GoogleFonts.itim(
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('ingredients')
                  .where('recipes_id', isEqualTo: widget.recipesId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final ingredients = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ingredients.length,
                  itemBuilder: (context, index) {
                    final ingrName = ingredients[index]['name'];
                    final quantity = ingredients[index]['quantity'];
                    final unit = ingredients[index]['unit'];
                    return ListTile(
                      title: Text(
                        "- $ingrName $quantity $unit",
                        style: GoogleFonts.itim(),
                      ),
                    );
                  },
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'วิธีทำ',
                style: GoogleFonts.itim(
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            FutureBuilder<QuerySnapshot>(
              future: _firestore
                  .collection('recipes')
                  .where('recipes_id', isEqualTo: widget.recipesId)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'ไม่มีข้อมูลวิธีทำ',
                      style: GoogleFonts.itim(fontSize: 16),
                    ),
                  );
                }

                final recipeData =
                    snapshot.data!.docs.first.data() as Map<String, dynamic>;
                final method = recipeData['method'] ?? 'ไม่มีข้อมูลวิธีทำ';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    method,
                    style: GoogleFonts.itim(fontSize: 16),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipesRatingPage(
                        recipesId: widget.recipesId,
                        name: widget.name,
                        imageUrl: widget.imageUrl,
                      ),
                    ),
                  );
                },
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(const Size(350, 50)),
                  backgroundColor: WidgetStateProperty.all(Colors.green),
                ),
                child: Text(
                  'ให้คะแนนสูตรอาหาร',
                  style: GoogleFonts.itim(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
