import 'package:flutter/material.dart';

class Changepass extends StatefulWidget {
  const Changepass({super.key});

  @override
  State<Changepass> createState() => _ChangepassState();
}

class _ChangepassState extends State<Changepass> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              })),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 130),
                  const Text(
                    "เปลี่ยนรหัสผ่าน",
                    style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: "ชื่อผู้ใช้",
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: "รหัสผ่านเก่า",
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: "รหัสผ่านใหม่",
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      obscureText: true, // ซ่อนรหัสผ่าน
                      decoration: const InputDecoration(
                        labelText: "ยืนยันรหัสผ่านใหม่",
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      minimumSize: WidgetStateProperty.all(const Size(350, 50)),
                      backgroundColor: WidgetStateProperty.all(Colors.green),
                    ),
                    child: const Text(
                      "เปลี่ยนรหัสผ่าน",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
