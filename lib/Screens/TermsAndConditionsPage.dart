import 'package:flutter/material.dart';
import 'package:foodallergies_app/Screens/FallergiesPage.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({super.key});

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  bool _isAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        title: Text(
          "เงื่อนไขและข้อตกลงเข้าใช้งาน",
          style: GoogleFonts.itim(color: Colors.white, fontSize: 30),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      "โปรดอ่านข้อตกลงนี้อย่างละเอียดก่อนใช้งานแอปพลิเคชันของเรา",
                      style: GoogleFonts.itim(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        // color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _buildTermsContent(),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: _isAccepted,
                  onChanged: (value) {
                    setState(() {
                      _isAccepted = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    "ข้าพเจ้ายอมรับข้อตกลงและเงื่อนไขการให้บริการนี้",
                    style: GoogleFonts.itim(fontSize: 14),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _isAccepted ? () => _onAccept(context) : null,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  _isAccepted ? Colors.lightGreen : Colors.grey,
                ),
                minimumSize: WidgetStateProperty.all(const Size(150, 50)),
              ),
              child: Text(
                "ยอมรับ",
                style: GoogleFonts.itim(fontSize: 24, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsContent() {
    return Text(
      """
1. วัตถุประสงค์
แอปพลิเคชันนี้ถูกพัฒนาเพื่อการนำเสนออาหารสำหรับผู้แพ้อาหาร โดยมุ่งเน้นในการแนะนำเมนูอาหารที่ปราศจากสารก่อภูมิแพ้ที่ระบุไว้

2. ข้อจำกัด
แอปพลิเคชันนี้ไม่สามารถระบุหรือประเมินการแพ้สารอาหารทั้งหมดได้ ผู้ใช้ควรใช้วิจารณญาณของตนเองและปรึกษาแพทย์หรือนักโภชนาการก่อนที่จะบริโภคอาหารใด ๆ ที่แนะนำโดยแอปพลิเคชัน

3. การไม่รับผิดชอบ
เราไม่รับผิดชอบต่อการเกิดอาการแพ้หรือปัญหาสุขภาพใดๆ ที่อาจเกิดขึ้นจากการใช้งานแอปพลิเคชันหรือการบริโภคอาหารที่แนะนำโดยแอปพลิเคชันนี้ ผู้ใช้ยอมรับความเสี่ยงและความรับผิดชอบทั้งหมดในการใช้งานแอปพลิเคชันนี้

4. การเก็บรวบรวมข้อมูล
เราอาจมีการเก็บรวบรวมข้อมูลการใช้งานและข้อมูลส่วนบุคคลของผู้ใช้ตามนโยบายความเป็นส่วนตัวของเรา โปรดอ่านนโยบายความเป็นส่วนตัวเพื่อทราบข้อมูลเพิ่มเติม

5. การแก้ไขข้อตกลง
เราขอสงวนสิทธิ์ในการแก้ไขหรือปรับปรุงข้อตกลงนี้ได้ทุกเมื่อ โดยจะแจ้งให้ผู้ใช้ทราบล่วงหน้า การใช้งานแอปพลิเคชันหลังจากมีการแก้ไขข้อตกลงถือว่าผู้ใช้ยอมรับข้อตกลงที่แก้ไขนั้นแล้ว

หากคุณมีข้อสงสัยหรือคำถามเกี่ยวกับข้อตกลงนี้ โปรดติดต่อเราที่ sirasith.klin@bumail.net

โดยการกด "ยอมรับ" คุณยืนยันว่าคุณได้อ่านและยอมรับข้อตกลงการใช้งานแอปพลิเคชันนี้ทั้งหมด
      """,
      style: GoogleFonts.itim(fontSize: 16),
    );
  }

  void _onAccept(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => FirstAllergiesPage(context)));
  }
}
