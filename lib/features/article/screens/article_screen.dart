import 'package:flutter/material.dart';

class ArticleScreen extends StatelessWidget {
  final String id;
  const ArticleScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Article')),
      body: Center(child: Text('Article Screen Placeholder for ID: $id')),
    );
  }
}
