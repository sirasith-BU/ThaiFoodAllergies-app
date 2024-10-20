import 'package:flutter/material.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  List<Map<String, String>> favoriteItems = [
    {
      'name': 'ข้าวผัดกะเพรา',
      'details': 'ข้าวผัดกะเพราหมูราดข้าว',
      'image':
          'https://www.thammculture.com/wp-content/uploads/2024/01/Untitled-612.jpg', // ใช้ URL หรือ Asset ของรูปภาพจริง
    },
    {
      'name': 'ต้มยำกุ้ง',
      'details': 'ต้มยำกุ้งรสจัดจ้าน',
      'image':
          'https://d3h1lg3ksw6i6b.cloudfront.net/media/image/2023/04/24/5608757681874e1ea5df1aa41d5b2e3d_How_To_Make_Tom_Yam_Kung_The_Epitome_Of_Delicious_And_Nutritious_Thai_Cuisine3.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text('รายการโปรด',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
        backgroundColor: Colors.green,
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.favorite, color: Colors.white)),
        ],
      ),
      body: favoriteItems.isEmpty
          ? Center(child: Text('ไม่มีรายการโปรด'))
          : ListView.builder(
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                final item = favoriteItems[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Image.network(
                        item['image']!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(item['name']!),
                      subtitle: Text(item['details']!),
                      trailing: IconButton(
                        icon: Icon(Icons.favorite),
                        color: Colors.red,
                        onPressed: () {
                          setState(() {
                            favoriteItems.removeAt(index);
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
