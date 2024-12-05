import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodallergies_app/Screens/ViewProfilePage.dart';
import 'package:foodallergies_app/auth/firebase_auth_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'RecipesRatingPage.dart';
import 'package:fl_chart/fl_chart.dart';

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

Future<String> getImagePath(String imageName) async {
  final Directory appDir = await getApplicationDocumentsDirectory();
  return '${appDir.path}/$imageName';
}

Widget _RecipeOverallRating(int recipesId) {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  return StreamBuilder<QuerySnapshot>(
    stream: firestore
        .collection('recipeRating')
        .where('recipes_id', isEqualTo: recipesId)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final ratings = snapshot.data!.docs;

      if (ratings.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "",
            style: GoogleFonts.itim(fontSize: 18),
          ),
        );
      }
      // if (ratings.isEmpty) {
      //   return Padding(
      //     padding: const EdgeInsets.all(16),
      //     child: Text(
      //       "ยังไม่มีการให้คะแนน",
      //       style: GoogleFonts.itim(fontSize: 18),
      //     ),
      //   );
      // }

      double totalAvgScore = 0;
      double totalTasteRating = 0;
      double totalDifficultRating = 0;
      double totalPresentRating = 0;
      int count = ratings.length;

      List<Future<void>> futureList = [];

      // Step 1: ดึงคำถามจาก askRating
      String qTasteRating = '';
      String qDifficultRating = '';
      String qPresentRating = '';

      for (var ratingDoc in ratings) {
        final askRatingId = ratingDoc['askRating_id'];

        Future<void> ratingFuture = firestore
            .collection('askRating')
            .doc(askRatingId)
            .get()
            .then((askRatingSnapshot) {
          if (askRatingSnapshot.exists) {
            final askRating = askRatingSnapshot.data();
            final tasteRating = askRating?['taste_rating'] ?? 0;
            final difficultRating = askRating?['difficult_rating'] ?? 0;
            final presentRating = askRating?['present_rating'] ?? 0;

            totalTasteRating += tasteRating;
            totalDifficultRating += difficultRating;
            totalPresentRating += presentRating;

            totalAvgScore +=
                (tasteRating + difficultRating + presentRating) / 3;

            // ดึงคำถาม
            qTasteRating = askRating?['qTaste_rating'] ?? '';
            qDifficultRating = askRating?['qDifficult_rating'] ?? '';
            qPresentRating = askRating?['qPresent_rating'] ?? '';
          }
        });

        futureList.add(ratingFuture);
      }

      return FutureBuilder(
        future: Future.wait(futureList),
        builder: (context, futureSnapshot) {
          if (futureSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          double avgScore = totalAvgScore / count;
          double avgTaste = totalTasteRating / count;
          double avgDifficult = totalDifficultRating / count;
          double avgPresent = totalPresentRating / count;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'คะแนนโดยรวม',
                style: GoogleFonts.itim(
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                avgScore.toStringAsFixed(1),
                style: GoogleFonts.itim(fontSize: 100),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  // คำนวณสีของดาวตาม avgScore
                  return Icon(
                    Icons.star,
                    color: (index < avgScore.round())
                        ? Colors.yellow
                        : Colors.grey,
                    size: 40,
                  );
                }),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'การให้คะแนนจากผู้ใช้จำนวน $count คน',
                  style: GoogleFonts.itim(fontSize: 18),
                ),
              ),
              // Horizontal Chart for taste rating
              SizedBox(
                height: 250,
                width: 400,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 5,
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: avgTaste,
                                color: Colors.green,
                                width: 20,
                                borderRadius: BorderRadius.zero,
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: avgDifficult,
                                color: Colors.green,
                                width: 20,
                                borderRadius: BorderRadius.zero,
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 2,
                            barRods: [
                              BarChartRodData(
                                toY: avgPresent,
                                color: Colors.green,
                                width: 20,
                                borderRadius: BorderRadius.zero,
                              ),
                            ],
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: GoogleFonts.itim(fontSize: 14),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 100,
                              getTitlesWidget: (value, meta) {
                                switch (value.toInt()) {
                                  case 0:
                                    return RotatedBox(
                                      quarterTurns: -1,
                                      child: Text(
                                        qTasteRating,
                                        style: GoogleFonts.itim(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  case 1:
                                    return RotatedBox(
                                      quarterTurns: -1,
                                      child: Text(
                                        qDifficultRating,
                                        style: GoogleFonts.itim(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  case 2:
                                    return RotatedBox(
                                      quarterTurns: -1,
                                      child: Text(
                                        qPresentRating,
                                        style: GoogleFonts.itim(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  default:
                                    return const Text('');
                                }
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                switch (value.toInt()) {
                                  case 0:
                                    return RotatedBox(
                                      quarterTurns: -1,
                                      child: Text(
                                        avgTaste.toStringAsFixed(
                                            1), // แสดง avgTaste
                                        style: GoogleFonts.itim(fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  case 1:
                                    return RotatedBox(
                                      quarterTurns: -1,
                                      child: Text(
                                        avgDifficult.toStringAsFixed(
                                            1), // แสดง avgDifficult
                                        style: GoogleFonts.itim(fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  case 2:
                                    return RotatedBox(
                                      quarterTurns: -1,
                                      child: Text(
                                        avgPresent.toStringAsFixed(
                                            1), // แสดง avgPresent
                                        style: GoogleFonts.itim(fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  default:
                                    return const Text('');
                                }
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _CommentRecipes(int recipesId) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('recipeRating')
        .where('recipes_id', isEqualTo: recipesId)
        .orderBy('date', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final ratingDocs = snapshot.data!.docs;

      if (ratingDocs.isEmpty) {
        return const Center(
          child: Text(
            "",
            style: TextStyle(fontSize: 16),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: ratingDocs.length,
        itemBuilder: (context, index) {
          final ratingData = ratingDocs[index].data() as Map<String, dynamic>;
          final userId = ratingData['user_id'];
          final askRatingId = ratingData['askRating_id']; // ดึง askRating_id
          final date = ratingData['date'] ?? '';

          // ดึงข้อมูลจาก askRating
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('askRating')
                .doc(askRatingId) // ใช้ askRatingId ในการดึงข้อมูลจาก askRating
                .get(),
            builder: (context, askRatingSnapshot) {
              if (!askRatingSnapshot.hasData) {
                return const SizedBox.shrink(); // ไม่แสดงอะไรระหว่างรอข้อมูล
              }

              final askRatingDoc = askRatingSnapshot.data!;
              final askRatingData = askRatingDoc.data() as Map<String, dynamic>;

              final avgScore = (askRatingData['avgScore'] ?? 0).toDouble();
              final avgScorefix1 = avgScore.toStringAsFixed(1);
              final comment = askRatingData['comment'] ?? '';

              // ดึงข้อมูลผู้ใช้
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('user')
                    .doc(userId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox
                        .shrink(); // ไม่แสดงอะไรระหว่างรอข้อมูล
                  }

                  final userDoc = userSnapshot.data!;
                  final userData = userDoc.data() as Map<String, dynamic>;

                  final username = userData['username'] ?? 'ผู้ใช้ไม่ระบุชื่อ';

                  // เช็คว่ามีฟิลด์ profileImage หรือไม่
                  final profileImage = userData.containsKey('profileImage')
                      ? userData['profileImage']
                      : 'assets/defaultProfile.png';

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: GestureDetector(
                      onTap: () {
                        // นำทางไปยัง ViewProfilePage พร้อมส่ง userId
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewProfilePage(uid: userId),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              FutureBuilder<String>(
                                future: getImagePath(
                                    profileImage), // ใช้ฟังก์ชัน getImagePath
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator(); // แสดง Loading ระหว่างรอ
                                  } else if (snapshot.hasError) {
                                    return const Icon(
                                        Icons.error); // แสดง Error ถ้ามีปัญหา
                                  } else {
                                    final imagePath = snapshot.data;
                                    // ตรวจสอบว่าไฟล์มีอยู่ในเครื่องหรือไม่
                                    return CircleAvatar(
                                      radius: 24,
                                      backgroundImage: (imagePath != null &&
                                              File(imagePath).existsSync())
                                          ? FileImage(File(
                                              imagePath)) // ใช้ FileImage ถ้าไฟล์มี
                                          : (profileImage.startsWith('assets/')
                                              ? AssetImage(
                                                  profileImage) // ใช้ AssetImage ถ้าเป็นไฟล์จาก assets
                                              : const AssetImage(
                                                  'assets/defaultProfile.png')), // fallback ถ้าไม่พบไฟล์
                                    );
                                  }
                                },
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(username,
                                    style: GoogleFonts.itim(fontSize: 20)),
                              ),
                              Text(
                                date.toString(),
                                style: GoogleFonts.itim(
                                    fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              for (int i = 0; i < 5; i++)
                                Icon(
                                  Icons.star,
                                  color: i < avgScore.round()
                                      ? Colors.yellow
                                      : Colors.grey,
                                  size: 16,
                                ),
                              const SizedBox(width: 5),
                              Text("($avgScorefix1)"),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            comment,
                            style: GoogleFonts.itim(fontSize: 22),
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}

class _RecipesDetailPageState extends State<RecipesDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to continue")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: SingleChildScrollView(
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
                            widget.name,
                            style: GoogleFonts.itim(
                              textStyle: const TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                // fontWeight: FontWeight.bold,
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
                                    DateTime now = DateTime.now();
                                    String formattedDate =
                                        '${DateFormat('dd-MM').format(now)}-${(now.year + 543).toString()}';
                                    // เพิ่มสูตรลงใน Favorite
                                    await favCollection.add({
                                      'user_id': userId,
                                      'recipes_id': widget.recipesId,
                                      'date': formattedDate,
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
                    .where('user_id', isEqualTo: _auth.currentUser?.uid)
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
                        totalScore = askRating?['avgScore'] ?? 0;
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
                    fontSize: 24,
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
                    // ดึงข้อมูลแต่ละฟิลด์จากเอกสาร
                    final ingrName =
                        ingredients[index]['name'] ?? "ไม่มีข้อมูลวัตถุดิบ";
                    final quantity = ingredients[index]['quantity'] ?? "";
                    final unit = ingredients[index]['unit'] ?? "";

                    return Padding(
                      padding:
                          const EdgeInsets.only(left: 10, top: 0, bottom: 0),
                      child: Text(
                        "- $ingrName $quantity $unit", // รูปแบบข้อความตามที่ต้องการ
                        style: GoogleFonts.itim(fontSize: 20),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(
              height: 10,
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
                      style: GoogleFonts.itim(fontSize: 20),
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
                    style: GoogleFonts.itim(fontSize: 20),
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
            const SizedBox(height: 10),
            Container(child: _RecipeOverallRating(widget.recipesId)),
            const SizedBox(height: 10),
            Container(child: _CommentRecipes(widget.recipesId)),
          ],
        ),
      ),
    );
  }
}
