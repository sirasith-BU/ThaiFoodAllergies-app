import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'RecipesDetailPage.dart';
import '../auth/firebase_auth_services.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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

  Widget _buildImageSliderItem(String name, int recipeId, String? imageUrl) {
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
                        )
                      : Container(), // หากไม่มี URL รูปก็จะไม่แสดง
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
                  child: Text('รายการอาหารทั้งหมด',
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

                          return _buildImageSliderItem(name, recId, imageUrl);
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
