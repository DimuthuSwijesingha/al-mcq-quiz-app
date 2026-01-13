import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/mcq.dart';
import '../widgets/mcq_expandable_card.dart';


const Color primaryBlue = Color(0xFF1E3A8A);
const Color softBlue = Color(0xFFE0E7FF);

class MCQListScreen extends StatefulWidget {
  final String subjectId;
  final String lessonId;
  final String lessonName;

  const MCQListScreen({
    super.key,
    required this.subjectId,
    required this.lessonId,
    required this.lessonName,
  });

  @override
  State<MCQListScreen> createState() => _MCQListScreenState();
}

class _MCQListScreenState extends State<MCQListScreen> {
  Future<void> _resetState() async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: Text(
          widget.lessonName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('AL Subjects')
            .doc(widget.subjectId)
            .collection('Lessons')
            .doc(widget.lessonId)
            .collection('MCQs')
            .snapshots(),
        builder: (context, snapshot) {
          /// LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          /// ERROR
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          final mcqs = snapshot.data!.docs
              .map(
                (doc) => McqModel.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();

          /// EMPTY STATE
          if (mcqs.isEmpty) {
            return RefreshIndicator(
              onRefresh: _resetState,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'No MCQs available for this lesson',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _resetState,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: mcqs.length + 1,
              itemBuilder: (context, index) {
                /// HEADER (MCQ COUNT)
                if (index == 0) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: softBlue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.checklist, color: primaryBlue),
                        const SizedBox(width: 12),
                        Text(
                          '${mcqs.length} Questions',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final mcq = mcqs[index - 1];

                return McqExpandableCard(mcq: mcq);
              },
            ),
          );
        },
      ),
    );
  }
}
