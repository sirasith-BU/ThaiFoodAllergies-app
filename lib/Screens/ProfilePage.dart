import 'package:flutter/material.dart';
import 'LoginPage.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const Login()));
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            height: 200,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    "https://media.istockphoto.com/id/1182393436/vector/fast-food-seamless-pattern-with-vector-line-icons-of-hamburger-pizza-hot-dog-beverage.jpg?s=612x612&w=0&k=20&c=jlj-n_CNsrd13tkHwC7MVo0cGUyyc8YP6wJQdCvMUGw="), // ใช้รูปปกหลัง
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("images/logo.png"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 230.0, left: 16.0, right: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Thai Food Allergies',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        minimumSize: WidgetStateProperty.all(const Size(100, 50)),
                      ),
                      child: const Text('แก้ไขโปรไฟล์'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        minimumSize: WidgetStateProperty.all(const Size(100, 50)),
                      ),
                      child: const Text('แก้ไขรายการอาหารที่แพ้'),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                const Text(
                  'คำอธิบาย',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'ผมเป็นสายกิน หลงใหลในรสชาติอาหาร ชอบชิมอาหารไม่ว่าจะเป็น อาหารไทย อาหารต่างชาติ อาหารคาว อาหารหวาน ของกินเล่น ของกินจุกจิก ผมลองมาหมดแล้ว จะรีวิวแบบไม่กั๊ก บอกต่อแบบตรงไปตรงมา',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'สิ่งที่ชอบรับประทาน',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text('ผัดกะเพรา, ต้มจืด'),
                const SizedBox(height: 20),
                const Text(
                  'รายการอาหารที่แพ้',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text('นม, ไข่, กุ้ง, หมึก'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
