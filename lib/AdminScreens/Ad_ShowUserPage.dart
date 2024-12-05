import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodallergies_app/AdminScreens/Ad_EditUserDetailPage.dart';
import 'package:foodallergies_app/auth/firebase_auth_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

class ShowUserPage extends StatefulWidget {
  const ShowUserPage({super.key});

  @override
  State<ShowUserPage> createState() => _ShowUserPageState();
}

class _ShowUserPageState extends State<ShowUserPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String searchBy = 'ชื่อผู้ใช้'; // ตรงกับคีย์ใน searchOptions
  final _auth = AuthService();
  late String currentUserId;
  final Map<String, String> searchOptions = {
    'ชื่อผู้ใช้': 'username',
    'อีเมล': 'email',
    'ชื่อจริง': 'firstname',
    'นามสกุล': 'lastname',
  };

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser?.uid ?? '';
  }

  // ฟังก์ชันค้นหาผู้ใช้จาก Firebase
  Future<List<DocumentSnapshot>> _searchUsers(String query) async {
    String searchKey = searchOptions[searchBy] ?? 'username'; // ใช้ค่า mapping
    QuerySnapshot result;

    if (query.isEmpty) {
      result = await _firestore.collection('user').get();
    } else {
      result = await _firestore
          .collection('user')
          .where(searchKey, isGreaterThanOrEqualTo: query)
          .where(searchKey, isLessThanOrEqualTo: '$query\uf8ff')
          .get();
    }

    // กรองไม่ให้แสดง current user
    return result.docs.where((doc) => doc.id != currentUserId).toList();
  }

  Future<String?> getImagePath(String? imageName) async {
    if (imageName == null) return null;
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String filePath = '${appDir.path}/$imageName';
    return filePath;
  }

  // ฟังก์ชันแสดงข้อมูลผู้ใช้ในรายการ
  Widget _buildUserItem(DocumentSnapshot userDoc) {
    String username = userDoc['username'] ?? '';
    String email = userDoc['email'] ?? '';
    bool isAdmin = (userDoc.data() as Map<String, dynamic>)['isAdmin'] == true;
    bool isDisabled =
        (userDoc.data() as Map<String, dynamic>)['isDisabled'] == true;

    // ตรวจสอบว่ามี 'profileImage' ในเอกสารหรือไม่
    String profileImage =
        (userDoc.data() as Map<String, dynamic>?)?['profileImage'] ??
            'assets/defaultProfile.png'; // ใช้ default ถ้าไม่มี profileImage

    return Card(
      elevation: 3,
      color: isDisabled
          ? Colors.grey[300]
          : Colors.white, // เปลี่ยนสีพื้นหลังเมื่อ isDisabled
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // ทำมุมมน
        side: BorderSide(
          color: isDisabled
              ? Colors.grey // ขอบสีเทาเมื่อ isDisabled
              : (isAdmin
                  ? Colors.orange
                  : Colors.green), // ขอบตาม admin หรือ user ปกติ
          width: 2, // ความหนาของขอบ
        ),
      ),
      child: ListTile(
        leading: FutureBuilder<String?>(
          future: getImagePath(profileImage),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Icon(Icons.error);
            } else {
              final imagePath = snapshot.data;
              ImageProvider backgroundImage;

              if (imagePath != null && File(imagePath).existsSync()) {
                backgroundImage = FileImage(File(imagePath));
              } else {
                backgroundImage = const AssetImage("assets/defaultProfile.png");
              }

              // Adding the ColorFiltered and ClipOval logic
              return CircleAvatar(
                radius: 25, // Adjusted size
                backgroundColor: Colors.transparent,
                child: ClipOval(
                  child: ColorFiltered(
                    colorFilter: isDisabled
                        ? const ColorFilter.mode(
                            Colors
                                .grey, // Change the image to grayscale if disabled
                            BlendMode.saturation,
                          )
                        : const ColorFilter.mode(
                            Colors.transparent, // Use the normal image
                            BlendMode.multiply,
                          ),
                    child: Image(
                      image: backgroundImage,
                      width: 50, // Ensure consistent size
                      height: 50,
                      fit:
                          BoxFit.cover, // Make the image fill the circular area
                    ),
                  ),
                ),
              );
            }
          },
        ),
        title: Text(
          username,
          style: GoogleFonts.itim(
            fontSize: 18,
            color: isDisabled
                ? Colors.grey
                : Colors.black, // ตัวหนังสือสีเทาเมื่อ isDisabled
          ),
        ),
        subtitle: Text(
          email,
          style: GoogleFonts.itim(
            fontSize: 14,
            color: isDisabled
                ? Colors.grey
                : Colors.black54, // ตัวหนังสือสีเทาเมื่อ isDisabled
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.orange, size: 40),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditUserDetailPage(userId: userDoc.id),
              ),
            ).then((value) {
              if (value == true) {
                setState(() {
                  // ทำการรีเฟรชข้อมูลที่นี่
                });
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ช่องค้นหาผู้ใช้
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'ค้นหาผู้ใช้',
                labelStyle: GoogleFonts.itim(),
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (query) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            // ตัวเลือกการค้นหาด้วย
            SizedBox(
              width: 150,
              child: DropdownButtonFormField<String>(
                value: searchBy, // ค่าที่เลือกเริ่มต้น
                onChanged: (String? newValue) {
                  setState(() {
                    searchBy = newValue!; // อัปเดตค่าตัวเลือก
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'ค้นหาโดย',
                  border: OutlineInputBorder(),
                ),
                items: searchOptions.keys
                    .map<DropdownMenuItem<String>>((String key) {
                  return DropdownMenuItem<String>(
                    value: key, // ใช้คีย์ภาษาไทยตรงกับค่าใน searchOptions
                    child: Text(key), // แสดงคีย์ภาษาไทยใน Dropdown
                  );
                }).toList(),
                dropdownColor: Colors.white ,
              ),
            ),
            const SizedBox(height: 16),
            // แสดงรายชื่อผู้ใช้
            Expanded(
              child: FutureBuilder<List<DocumentSnapshot>>(
                future: _searchUsers(_searchController.text),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('ไม่พบผู้ใช้'));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return _buildUserItem(snapshot.data![index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
