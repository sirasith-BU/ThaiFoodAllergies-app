import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'RecipesDetailPage.dart';
import '../auth/firebase_auth_services.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? username;
  String? profileImage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<Map<String, dynamic>?> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore.collection("user").doc(user.uid).get();
      return snapshot.data();
    }
    return null;
  }

  Future<String?> getImagePath(String? imageName) async {
    if (imageName == null) return null;
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String filePath = '${appDir.path}/$imageName';
    return filePath;
  }

  Widget _allRecipes(String name, int recipeId, String? imageUrl) {
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
                imageUrl: imageUrl ?? '', // ใช้ค่า imageUrl จาก Firestore
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
                  // ใช้ Image.network เพื่อแสดงรูปจาก Firestore
                  imageUrl != null && imageUrl.isNotEmpty
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
                  // หากไม่มี URL รูปก็จะไม่แสดง
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
                            color: Colors.white,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('favorite')
                          .where('user_id', isEqualTo: _auth.currentUser?.uid)
                          .where('recipes_id', isEqualTo: recipeId)
                          .limit(1)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        bool isFavorite = snapshot.data!.docs.isNotEmpty;
                        return GestureDetector(
                          onTap: () async {
                            if (_auth.currentUser == null) return;

                            final favCollection = FirebaseFirestore.instance
                                .collection('favorite');
                            final favoriteDoc = await favCollection
                                .where('user_id',
                                    isEqualTo: _auth.currentUser!.uid)
                                .where('recipes_id', isEqualTo: recipeId)
                                .limit(1)
                                .get();

                            if (favoriteDoc.docs.isEmpty) {
                              await favCollection.add({
                                'user_id': _auth.currentUser!.uid,
                                'recipes_id': recipeId,
                                'date': DateFormat('dd-MM-yyyy')
                                    .format(DateTime.now()),
                                'time': DateFormat('HH:mm:ss')
                                    .format(DateTime.now()),
                              });
                            } else {
                              await favCollection
                                  .doc(favoriteDoc.docs.first.id)
                                  .delete();
                            }
                          },
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.white,
                            size: 30,
                          ),
                        );
                      },
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

  Widget _reviewRecipes(String name, int recipeId, String? imageUrl) {
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
                imageUrl: imageUrl ?? '',
              ),
            ),
          );
        },
        child: AspectRatio(
          aspectRatio: 1 / 1,
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
                  // แสดงภาพจาก Firestore
                  imageUrl != null && imageUrl.isNotEmpty
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
                      color: Colors.black.withOpacity(0.7),
                      padding: const EdgeInsets.all(8),
                      child: FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('recipeRating')
                            .where('recipes_id', isEqualTo: recipeId)
                            .limit(1)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Text(
                              'ยังไม่มีรีวิว',
                              style: TextStyle(color: Colors.white),
                            );
                          }

                          // ดึงข้อมูล recipeRating
                          final recipeRatingData = snapshot.data!.docs.first;
                          final askRatingId = recipeRatingData['askRating_id'];
                          final userId =
                              recipeRatingData['user_id']; // ดึง user_id
                          final date =
                              recipeRatingData['date'] ?? 'ไม่ระบุวันที่';

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('askRating')
                                .doc(askRatingId)
                                .get(),
                            builder: (context, askRatingSnapshot) {
                              if (askRatingSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (!askRatingSnapshot.hasData ||
                                  askRatingSnapshot.data == null) {
                                return const Text(
                                  'ยังไม่มีรีวิว',
                                  style: TextStyle(color: Colors.white),
                                );
                              }

                              // ดึงข้อมูล askRating
                              final askRatingData = askRatingSnapshot.data!
                                  .data() as Map<String, dynamic>;
                              final avgScore = askRatingData['avgScore'] ?? 0.0;
                              final comment = askRatingData['comment'] ??
                                  'ไม่มีความคิดเห็น';

                              // ดึงข้อมูล user โดยใช้ userId
                              return FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('user')
                                    .doc(userId)
                                    .get(),
                                builder: (context, userSnapshot) {
                                  if (userSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  if (!userSnapshot.hasData ||
                                      userSnapshot.data == null) {
                                    return const Text(
                                      'ไม่พบข้อมูลผู้ใช้',
                                      style: TextStyle(color: Colors.white),
                                    );
                                  }

                                  // ดึงข้อมูล user
                                  final userData = userSnapshot.data!.data()
                                      as Map<String, dynamic>;
                                  final profileImage = userData[
                                          'profileImage'] ??
                                      'assets/defaultProfile.png'; // รูปโปรไฟล์
                                  final username = userData['username'] ??
                                      'ผู้ใช้'; // ชื่อผู้ใช้

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: GoogleFonts.itim(
                                          textStyle: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.yellow,
                                                size: 20,
                                              ),
                                              Text(
                                                avgScore.toStringAsFixed(1),
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          // แสดงวันที่รีวิว
                                          Text(
                                            date.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        padding: const EdgeInsets.all(8),
                                        color: Colors.white.withOpacity(0.2),
                                        child: Text(
                                          comment,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          ClipOval(
                                            child: profileImage
                                                    .startsWith('assets/')
                                                ? Image.asset(
                                                    profileImage,
                                                    width: 30,
                                                    height: 30,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.network(
                                                    profileImage,
                                                    width: 30,
                                                    height: 30,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            username,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
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
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("ไม่พบข้อมูลผู้ใช้"));
          }

          final userData = snapshot.data!;
          final username = userData['username'] ?? '';
          final profileImageName = userData['profileImage'];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.green,
                  padding: const EdgeInsets.only(top: 60, left: 20),
                  height: 150,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String?>(
                        future: getImagePath(profileImageName),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return const Icon(Icons.error);
                          } else {
                            final imagePath = snapshot.data;
                            return CircleAvatar(
                              radius: 38,
                              backgroundImage: imagePath != null
                                  ? FileImage(File(imagePath))
                                  : const AssetImage(
                                          'assets/defaultProfile.png')
                                      as ImageProvider,
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('สวัสดีคุณ $username',
                                style: GoogleFonts.itim(
                                  textStyle: const TextStyle(
                                      fontSize: 30,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                            const SizedBox(height: 4),
                            Text(
                              'วันนี้คุณทำเมนูอะไรดี?',
                              style: GoogleFonts.itim(
                                  textStyle: const TextStyle(
                                      fontSize: 20, color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('รายการสูตรอาหารทั้งหมด',
                      style: GoogleFonts.itim(
                        textStyle: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ),
                SizedBox(
                  height: 270,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('recipes')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final recipeDocument = snapshot.data!.docs[index];
                          final imageUrl =
                              recipeDocument['image']; // ใช้ค่าภาพจาก Firestore
                          final name = recipeDocument["name"];
                          final recId = recipeDocument["recipes_id"];

                          return _allRecipes(name, recId, imageUrl);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('สูตรอาหารที่มีรีวิว',
                      style: GoogleFonts.itim(
                        textStyle: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ),
                SizedBox(
                  height: 250,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('recipeRating')
                        .snapshots(),
                    builder: (context, recipeRatingSnapshot) {
                      if (!recipeRatingSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final ratedRecipeIds = recipeRatingSnapshot.data!.docs
                          .map((doc) => doc['recipes_id'])
                          .toSet();

                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('recipes')
                            .snapshots(),
                        builder: (context, recipeSnapshot) {
                          if (!recipeSnapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final recipesWithRating = recipeSnapshot.data!.docs
                              .where((doc) =>
                                  ratedRecipeIds.contains(doc['recipes_id']))
                              .toList();

                          if (recipesWithRating.isEmpty) {
                            return const Center(
                                child: Text('ไม่มีสูตรอาหารที่มีรีวิว'));
                          }

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: recipesWithRating.length,
                            itemBuilder: (context, index) {
                              final recipeDoc = recipesWithRating[index];
                              final imageUrl = recipeDoc['image'];
                              final name = recipeDoc['name'];
                              final recId = recipeDoc['recipes_id'];

                              return _reviewRecipes(name, recId, imageUrl);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
