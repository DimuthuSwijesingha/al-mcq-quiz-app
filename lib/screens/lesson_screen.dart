import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mcq_list_screen.dart';

const Color primaryBlue = Color(0xFF1E3A8A);
const Color softBlue = Color(0xFFE0E7FF);

class LessonScreen extends StatelessWidget {
  final String examType;
  final String subjectId;
  final String subjectName;

  const LessonScreen({
    super.key,
    required this.examType,
    required this.subjectId,
    required this.subjectName,
  });

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: Text(
          subjectName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('AL Subjects')
            .doc(subjectId)
            .collection('Lessons')
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

          final lessons = snapshot.data!.docs;

          /// EMPTY STATE
          if (lessons.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'No lessons available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                final lessonName = lesson['name'];

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TIMELINE DOT
                    Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (index != lessons.length - 1)
                          Container(
                            width: 2,
                            height: 60,
                            color: primaryBlue.withOpacity(0.3),
                          ),
                      ],
                    ),

                    const SizedBox(width: 16),

                    /// LESSON CARD
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MCQListScreen(
                                subjectId: subjectId,
                                lessonId: lesson.id,
                                lessonName: lessonName,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: softBlue,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.play_lesson,
                                size: 32,
                                color: primaryBlue,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  lessonName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primaryBlue,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: primaryBlue,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
