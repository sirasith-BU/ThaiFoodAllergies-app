import 'package:flutter/material.dart';
import 'package:foodallergies_app/AdminScreens/Ad_ShowUserPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Ad_SearchPage.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminSearchPage(),
    const ShowUserPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'สูตรอาหาร',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'บัญชีผู้ใช้',
          ),
        ],
        currentIndex: _selectedIndex,
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
