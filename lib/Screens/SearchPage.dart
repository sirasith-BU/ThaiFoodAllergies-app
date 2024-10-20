import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String selectedFilter = 'ทั้งหมด';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'กินอะไรดี..',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter = 'ทั้งหมด';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedFilter == 'ทั้งหมด'
                        ? Colors.green
                        : Colors.grey,
                    minimumSize: const Size(120, 50),
                  ),
                  child: Text(
                    'ทั้งหมด',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: selectedFilter == 'ทั้งหมด'
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter = 'ของคาว';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedFilter == 'ของคาว' ? Colors.green : Colors.grey,
                    minimumSize: const Size(120, 50),
                  ),
                  child: Text('ของคาว',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: selectedFilter == 'ของคาว'
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter = 'ของหวาน';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedFilter == 'ของหวาน'
                        ? Colors.green
                        : Colors.grey,
                    minimumSize: const Size(120, 50),
                  ),
                  child: Text('ของหวาน',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: selectedFilter == 'ของหวาน'
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Text(
                  selectedFilter,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
