import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class RecipesRatingPage extends StatefulWidget {
  final int recipesId;
  final String name;
  final String imageUrl;

  const RecipesRatingPage({
    super.key,
    required this.recipesId,
    required this.name,
    required this.imageUrl,
  });

  @override
  _RecipesRatingPageState createState() => _RecipesRatingPageState();
}

class _RecipesRatingPageState extends State<RecipesRatingPage> {
  int tasteRating = 0;
  int difficultyRating = 0;
  int presentationRating = 0;
  final TextEditingController commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadExistingRating();
  }

  Future<void> _loadExistingRating() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return; // ถ้ายังไม่ได้ล็อกอิน, ไม่ต้องดึงข้อมูล
    }

    // ดึงข้อมูลการให้คะแนนจาก recipeRating
    final recipeRatingDoc = await _firestore
        .collection('recipeRating')
        .where('recipes_id', isEqualTo: widget.recipesId)
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();

    if (recipeRatingDoc.docs.isNotEmpty) {
      // มีการให้คะแนนแล้ว
      final recipeRating = recipeRatingDoc.docs.first;
      final askRatingId = recipeRating['askRating_id'];

      // ดึงข้อมูลจาก askRating
      final askRatingDoc =
          await _firestore.collection('askRating').doc(askRatingId).get();

      if (askRatingDoc.exists) {
        final askRating = askRatingDoc.data();
        setState(() {
          tasteRating = askRating?['taste_rating'] ?? 0;
          difficultyRating = askRating?['difficult_rating'] ?? 0;
          presentationRating = askRating?['present_rating'] ?? 0;
          commentController.text = askRating?['comment'] ?? '';
        });
      }
    }
  }

  Future<void> submitRating() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to submit a rating.")),
      );
      return;
    }

    // เพิ่มหรืออัปเดตการให้คะแนนใน askRating collection
    final askRatingRef = await _firestore.collection('askRating').add({
      'qTaste_rating': "รสชาติอาหาร",
      'qDifficult_rating': "ความยากในการทำ",
      'qPresent_rating': "การนำเสนออาหาร",
      'taste_rating': tasteRating,
      'difficult_rating': difficultyRating,
      'present_rating': presentationRating,
      'avgScore': (tasteRating + difficultyRating + presentationRating) / 3,
      'comment': commentController.text,
    });

    // ตรวจสอบว่ามีการให้คะแนนอยู่แล้วใน recipeRating หรือไม่
    final recipeRatingDoc = await _firestore
        .collection('recipeRating')
        .where('recipes_id', isEqualTo: widget.recipesId)
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();

    if (recipeRatingDoc.docs.isEmpty) {
      // ไม่มีการให้คะแนนเลย, สร้างใหม่
      await _firestore.collection('recipeRating').add({
        'recipes_id': widget.recipesId,
        'user_id': userId,
        'date': DateFormat('dd-MM-yyyy').format(DateTime.now()),
        'time': DateFormat('HH:mm:ss').format(DateTime.now()),
        'askRating_id': askRatingRef.id, // อ้างอิงไปยัง askRating ที่เพิ่งสร้าง
      });
    } else {
      // ถ้ามีการให้คะแนนอยู่แล้ว, อัปเดต
      await _firestore
          .collection('recipeRating')
          .doc(recipeRatingDoc.docs.first.id)
          .update({
        'date': DateFormat('dd-MM-yyyy').format(DateTime.now()),
        'time': DateFormat('HH:mm:ss').format(DateTime.now()),
        'askRating_id': askRatingRef.id, // อัปเดต askRating_id
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Rating submitted successfully.")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  widget.imageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      widget.name,
                      style: GoogleFonts.itim(
                        textStyle: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            buildRatingSection("รสชาติอาหาร", "ไม่อร่อย", "อร่อยมาก",
                (rating) => setState(() => tasteRating = rating)),
            buildRatingSection("ความยากในการทำ", "ไม่ยากเลย", "ยากมาก",
                (rating) => setState(() => difficultyRating = rating)),
            buildRatingSection("การนำเสนออาหาร", "นำเสนอแย่", "นำเสนอดีมาก",
                (rating) => setState(() => presentationRating = rating)),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: commentController,
                decoration: InputDecoration(
                  labelText: "แสดงความคิดเห็น",
                  labelStyle: GoogleFonts.itim(),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: submitRating,
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(const Size(350, 50)),
                  backgroundColor: WidgetStateProperty.all(Colors.green),
                ),
                child: Text(
                  'ให้คะแนน',
                  style: GoogleFonts.itim(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget buildRatingSection(String title, String minLabel, String maxLabel,
      void Function(int) onRatingSelected) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.itim(
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  minLabel,
                  style: GoogleFonts.itim(),
                ),
                Text(
                  maxLabel,
                  style: GoogleFonts.itim(),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      Icons.star,
                      color: (index < getRatingValue(title))
                          ? Colors.yellow
                          : Colors.grey,
                      size: 58,
                    ),
                    onPressed: () {
                      onRatingSelected(index + 1);
                    },
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int getRatingValue(String title) {
    switch (title) {
      case "รสชาติอาหาร":
        return tasteRating;
      case "ความยากในการทำ":
        return difficultyRating;
      case "การนำเสนออาหาร":
        return presentationRating;
      default:
        return 0;
    }
  }
}
