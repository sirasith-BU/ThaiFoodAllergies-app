import 'package:flutter/material.dart';
import 'MainPage.dart';

class Fallergies extends StatefulWidget {
  const Fallergies({super.key});

  @override
  State<Fallergies> createState() => _FallergiesState();
}

class _FallergiesState extends State<Fallergies> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        backgroundColor: Colors.green,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => (MainPage())));
            },
            child: Text(
              'Skip',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "กรุณากรอกอาหารที่แพ้",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 37),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "กรุณากรอกอาหารที่แพ้ เช่น นม",
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: Text(
                  "บันทึก",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.lightGreen),
                  minimumSize: WidgetStateProperty.all(Size(150, 50)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
