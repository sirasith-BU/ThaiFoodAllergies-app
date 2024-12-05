import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class ViewProfilePage extends StatefulWidget {
  final String uid; // รับ uid จาก constructor

  const ViewProfilePage({super.key, required this.uid});

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> _fetchUserData() async {
    final snapshot = await _firestore.collection("user").doc(widget.uid).get();
    return snapshot.data();
  }

  Future<List<String>> _fetchAllergicIngredients() async {
    final snapshot = await _firestore
        .collection("allergicFood")
        .where('user_id', isEqualTo: widget.uid)
        .get();
    return snapshot.docs.map((doc) => doc['allergic_ingr'] as String).toList();
  }

  Future<String> getImagePath(String imageName) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/$imageName';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // automaticallyImplyLeading: false,
      ),
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
          final fname = userData['firstname'] ?? '';
          final lname = userData['lastname'] ?? '';
          final username = userData['username'] ?? '';
          final birthdate = userData['birthDate'] ?? '';
          final gender = userData['gender'] ?? '';
          final profileImage = userData['profileImage'];
          final bgImage = userData['bgImage'];
          final aboutme = userData['aboutMe'] ?? '';

          return FutureBuilder<List<String>>(
            // Fetching allergic ingredients
            future: _fetchAllergicIngredients(),
            builder: (context, allergicSnapshot) {
              if (allergicSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final allergicFood = allergicSnapshot.data ?? [];
              final allergicFoodList = allergicFood.join(', ');

              return SingleChildScrollView(
                child: Stack(
                  children: [
                    FutureBuilder<String?>(
                      future: bgImage != null
                          ? getImagePath(bgImage)
                          : Future.value(null),
                      builder: (context, bgImageSnapshot) {
                        if (bgImageSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final bgImagePath = bgImageSnapshot.data;
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: (bgImagePath != null &&
                                      File(bgImagePath).existsSync())
                                  ? FileImage(File(bgImagePath))
                                      as ImageProvider
                                  : const AssetImage(
                                      "assets/defaultBackground.jpg"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 150,
                      left: MediaQuery.of(context).size.width / 2 - 50,
                      child: FutureBuilder<String?>(
                        future: profileImage != null
                            ? getImagePath(profileImage)
                            : Future.value(null),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return const Icon(Icons.error);
                          } else {
                            final imagePath = snapshot.data;
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: (imagePath != null &&
                                          File(imagePath).existsSync())
                                      ? FileImage(File(imagePath))
                                          as ImageProvider
                                      : const AssetImage(
                                          "assets/defaultProfile.png"),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 230.0, left: 16.0, right: 16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            "$fname $lname",
                            style: GoogleFonts.itim(
                                textStyle: const TextStyle(
                                    fontSize: 36, fontWeight: FontWeight.bold)),
                          ),
                          Text(
                            username,
                            style: GoogleFonts.itim(
                                textStyle: const TextStyle(fontSize: 26)),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.all(10),
                            width: 800,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "วันเกิด",
                                            style: GoogleFonts.itim(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            birthdate,
                                            style:
                                                GoogleFonts.itim(fontSize: 22),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "เพศ",
                                            style: GoogleFonts.itim(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            gender,
                                            style:
                                                GoogleFonts.itim(fontSize: 22),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                    height: 10), // เพิ่มระยะห่างระหว่างแถว
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "คำแนะนำตัวเอง",
                                            style: GoogleFonts.itim(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            aboutme,
                                            style:
                                                GoogleFonts.itim(fontSize: 22),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "รายการอาหารที่แพ้",
                                            style: GoogleFonts.itim(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            allergicFoodList,
                                            style:
                                                GoogleFonts.itim(fontSize: 22),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
