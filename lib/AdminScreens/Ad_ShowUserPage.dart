import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodallergies_app/AdminScreens/Ad_EditUserDetailPage.dart';
import 'package:google_fonts/google_fonts.dart';

class ShowUserPage extends StatefulWidget {
  const ShowUserPage({super.key});

  @override
  State<ShowUserPage> createState() => _ShowUserPageState();
}

class _ShowUserPageState extends State<ShowUserPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String searchBy = 'username'; // ตัวเลือกการค้นหาผู้ใช้

  // ฟังก์ชันค้นหาผู้ใช้จาก Firebase
  Future<List<DocumentSnapshot>> _searchUsers(String query) async {
    if (query.isEmpty) {
      // ถ้าไม่มีการกรอกคำค้นหา, แสดงผู้ใช้ทั้งหมด
      QuerySnapshot result = await _firestore.collection('user').get();
      return result.docs;
    } else {
      // หากกรอกคำค้นหามา, ให้ค้นหาตามเงื่อนไขที่เลือก
      QuerySnapshot result = await _firestore
          .collection('user')
          .where(searchBy, isGreaterThanOrEqualTo: query)
          .where(searchBy, isLessThanOrEqualTo: '$query\uf8ff')
          .get();
      return result.docs;
    }
  }

  // ฟังก์ชันแสดงข้อมูลผู้ใช้ในรายการ
  Widget _buildUserItem(DocumentSnapshot userDoc) {
    String username = userDoc['username'] ?? '';
    String email = userDoc['email'] ?? '';
    bool isAdmin = (userDoc.data() as Map<String, dynamic>)['admin'] == true;

    // ตรวจสอบว่ามี 'profileImage' ในเอกสารหรือไม่
    String profileImage =
        (userDoc.data() as Map<String, dynamic>?)?['profileImage'] ??
            'assets/defaultProfile.png'; // ใช้ default ถ้าไม่มี profileImage

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // ทำมุมมน
        side: BorderSide(
          color: isAdmin ? Colors.orange : Colors.green, // สีของขอบตาม admin
          width: 2, // ความหนาของขอบ
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage:
              AssetImage(profileImage), // โหลดรูปจาก Firebase หรือจาก assets
        ),
        title: Text(username, style: GoogleFonts.itim(fontSize: 18)),
        subtitle: Text(email, style: GoogleFonts.itim(fontSize: 14)),
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
      // appBar: AppBar(
      //   title: Text('ค้นหาผู้ใช้', style: GoogleFonts.itim(fontSize: 24)),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
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
              width: 150, // กำหนดความกว้างตามที่ต้องการ
              child: DropdownButtonFormField<String>(
                value: searchBy,
                onChanged: (String? newValue) {
                  setState(() {
                    searchBy = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'ค้นหาตาม', // ข้อความกำกับที่จะแสดง
                  border: OutlineInputBorder(),
                ),
                items: <String>[
                  'username',
                  'email',
                  'firstname',
                  'lastname',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
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
