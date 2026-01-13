import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_mcq_screen.dart';

const Color primaryBlue = Color(0xFF1E3A8A);
const Color softBlue = Color(0xFFE0E7FF);

class AdminMCQListScreen extends StatelessWidget {
  final String examType;
  final String subjectId;
  final String lessonId;

  const AdminMCQListScreen({
    super.key,
    required this.examType,
    required this.subjectId,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context) {
    final baseCollection =
        examType == 'AL' ? 'AL Subjects' : 'OL Subjects';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text(
          'Manage MCQs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(baseCollection)
            .doc(subjectId)
            .collection('Lessons')
            .doc(lessonId)
            .collection('MCQs')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final mcqs = snapshot.data!.docs;

          if (mcqs.isEmpty) {
            return const Center(
              child: Text(
                'No MCQs found',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: mcqs.length,
            itemBuilder: (context, index) {
              final mcq = mcqs[index];

              return _AdminMcqCard(
                mcq: mcq,
                examType: examType,
                subjectId: subjectId,
                lessonId: lessonId,
              );
            },
          );
        },
      ),
    );
  }
}

class _AdminMcqCard extends StatefulWidget {
  final QueryDocumentSnapshot mcq;
  final String examType;
  final String subjectId;
  final String lessonId;

  const _AdminMcqCard({
    required this.mcq,
    required this.examType,
    required this.subjectId,
    required this.lessonId,
  });

  @override
  State<_AdminMcqCard> createState() => _AdminMcqCardState();
}

class _AdminMcqCardState extends State<_AdminMcqCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.mcq.data() as Map<String, dynamic>;
    final options = List<String>.from(data['options']);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QUESTION HEADER
            GestureDetector(
              onTap: () {
                setState(() => expanded = !expanded);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['questionText'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Year: ${data['year']}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            // OPTIONS
            if (expanded) ...[
              const SizedBox(height: 12),
              ...List.generate(options.length, (i) {
                final isCorrect = i == data['correctOptionIndex'];

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? Colors.green.withOpacity(0.15)
                        : Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(options[i]),
                );
              }),
            ],

            const SizedBox(height: 12),

            // ADMIN ACTION BAR
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddMcqScreen(
                          examType: widget.examType,
                          subjectId: widget.subjectId,
                          lessonId: widget.lessonId,
                          existingMcq: widget.mcq,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 8),

                TextButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete MCQ'),
                        content: const Text(
                          'Are you sure you want to delete this MCQ?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await widget.mcq.reference.delete();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
