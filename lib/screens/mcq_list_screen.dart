import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/mcq.dart';
import 'package:flutter_application_1/widgets/mcq_card.dart';


class MCQListScreen extends StatelessWidget {
  const MCQListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MCQs')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('AL Subjects')
            .doc('Physics')
            .collection('Lessons')
            .doc('Motion')
            .collection('MCQs')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final mcqs = snapshot.data!.docs
              .map((doc) => McqModel.fromFirestore(doc.data() as Map<String, dynamic>))
              .toList();

          return ListView.builder(
            itemCount: mcqs.length,
            itemBuilder: (context, index) {
              final mcq = mcqs[index];

              return McqCard(mcq: mcq);

            },
          );
        },
      ),
    );
  }
}
