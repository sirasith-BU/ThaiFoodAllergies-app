import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foodallergies_app/Screens/EditAllergiesPage.dart';
import 'package:foodallergies_app/auth/firebase_auth_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'LoginPage.dart';
import 'ProfileEditPage.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _auth = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? profileImagePath;
  String? bgImagePath;

  Future<Map<String, dynamic>?> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore.collection("user").doc(user.uid).get();
      return snapshot.data();
    }
    return null;
  }

  Future<List<String>> _fetchAllergicIngredients() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection("allergic_food")
          .where('user_id', isEqualTo: user.uid)
          .get();
      return snapshot.docs
          .map((doc) => doc['allergic_ingr'] as String)
          .toList();
    }
    return [];
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/${image.name}';
      await File(image.path).copy(filePath);
      setState(() {
        profileImagePath = filePath;
      });
      await _saveImagePathToFirestore(
          image.name, 'profileImage'); // Save as profileImage
    }
  }

  Future<void> _pickBgImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/${image.name}';
      await File(image.path).copy(filePath);
      setState(() {
        bgImagePath = filePath;
      });
      await _saveImagePathToFirestore(image.name, 'bgImage'); // Save as bgImage
    }
  }

  Future<String> getImagePath(String imageName) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/$imageName';
  }

  Future<void> _saveImagePathToFirestore(String imageName, String type) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection("user").doc(user.uid).update({
        type:
            imageName, // Save as either profileImage or bgImage based on the type
      });
    }
  }

  _signoutConfirm() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("การออกจากระบบ"),
        content: const Text("แน่ใจหรือว่าจะออกจากระบบ?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ปิด AlertDialog
            },
            child: const Text("ไม่"),
          ),
          TextButton(
            onPressed: () async {
              await _auth.signout();
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },
            child: const Text("ตกลง"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signoutConfirm,
          ),
        ],
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
                if (allergicSnapshot.connectionState ==
                    ConnectionState.waiting) {
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
                                image: bgImagePath != null
                                    ? FileImage(File(bgImagePath))
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
                                    backgroundImage: imagePath != null
                                        ? FileImage(File(imagePath))
                                        : const AssetImage(
                                                "assets/defaultProfile.png")
                                            as ImageProvider,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: _pickProfileImage,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.camera_alt,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                      Positioned(
                        top: 20,
                        right: 20,
                        child: GestureDetector(
                          onTap: _pickBgImage,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                              ),
                            ),
                          ),
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
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Text(
                              username,
                              style: GoogleFonts.itim(
                                  textStyle: const TextStyle(fontSize: 26)),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    bool? updated = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const EditProfilePage()),
                                    );
                                    if (updated == true) {
                                      // รีเฟรชข้อมูลในหน้าโปรไฟล์หลังจากที่บันทึกสำเร็จ
                                      setState(() {});
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all(Colors.green),
                                    minimumSize: WidgetStateProperty.all(
                                        const Size(100, 50)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.edit,
                                          color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text(
                                        'โปรไฟล์',
                                        style: GoogleFonts.itim(
                                            fontSize: 18, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    bool? updated = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const EditAllergiesPage()),
                                    );
                                    if (updated == true) {
                                      // รีเฟรชข้อมูลในหน้าโปรไฟล์หลังจากที่บันทึกสำเร็จ
                                      setState(() {});
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all(Colors.green),
                                    minimumSize: WidgetStateProperty.all(
                                        const Size(100, 50)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.edit,
                                          color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text(
                                        'รายการอาหารที่แพ้',
                                        style: GoogleFonts.itim(
                                            fontSize: 18, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // const SizedBox(height: 30),
                            Container(
                              padding: const EdgeInsets.all(10),
                              width: 800,
                              // decoration: BoxDecoration(
                              //   color: Colors.green[200],
                              //   borderRadius: BorderRadius.circular(8.0),
                              // ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "วันเกิด",
                                    style: GoogleFonts.itim(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    birthdate,
                                    style: GoogleFonts.itim(fontSize: 20),
                                  ),
                                  Text(
                                    "เพศ",
                                    style: GoogleFonts.itim(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    gender,
                                    style: GoogleFonts.itim(fontSize: 20),
                                  ),
                                  Text(
                                    "เกี่ยวกับฉัน",
                                    style: GoogleFonts.itim(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    aboutme,
                                    style: GoogleFonts.itim(fontSize: 20),
                                  ),
                                  Text("รายการอาหารที่แพ้",
                                      style: GoogleFonts.itim(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    allergicFoodList,
                                    style: GoogleFonts.itim(fontSize: 20),
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
              });
        },
      ),
    );
  }
}
