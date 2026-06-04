import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext materialContext) {
    return MaterialApp(
      title: 'Batak AI Test',
      theme: ThemeData.dark(),
      home: const AiTestScreen(),
    );
  }
}

class AiTestScreen extends StatefulWidget {
  const AiTestScreen({super.key});

  @override
  State<AiTestScreen> createState() => _AiTestScreenState();
}

class _AiTestScreenState extends State<AiTestScreen> {
  List<dynamic> _exercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAiVectors();
  }

  Future<void> _loadAiVectors() async {
    try {
      final String response = await rootBundle.loadString('assets/data/exercises_vectors.json');
      final data = await json.decode(response);
      setState(() {
        _exercises = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error loading vectors: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⚡ Batak AI Vector Test')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                final item = _exercises[index];
                return ListTile(
                  title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Primary: ${item['primary_muscle']} | Vector: ${item['vector']}"),
                );
              },
            ),
    );
  }
}
