import 'package:flutter/material.dart';
import 'package:foodallergies_app/AdminScreens/Ad_AddRecipesPage.dart';
import 'package:foodallergies_app/AdminScreens/Ad_ShowUserPage.dart';
import 'package:foodallergies_app/Screens/LoginPage.dart';
import 'package:foodallergies_app/auth/firebase_auth_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Ad_SearchPage.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _selectedIndex = 0;
  final _auth = AuthService();

  final List<Widget> _pages = [
    const AdminSearchPage(),
    const AdminAddRecipesPage(),
    const ShowUserPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
      backgroundColor: Colors.white,
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'สูตรอาหาร',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'เพิ่มสูตรอาหาร',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'บัญชีผู้ใช้',
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts
            .itim(), // ใช้ GoogleFonts.itim() สำหรับตัวเลือกที่ถูกเลือก
        unselectedLabelStyle: GoogleFonts
            .itim(), // ใช้ GoogleFonts.itim() สำหรับตัวเลือกที่ไม่ถูกเลือก
        onTap: _onItemTapped,
      ),
    );
  }
}
