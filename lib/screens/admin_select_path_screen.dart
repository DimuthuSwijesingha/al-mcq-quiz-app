import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_mcq_screen.dart';
import 'admin_mcq_list_screen.dart';

const Color primaryBlue = Color(0xFF1E3A8A);
const Color softBlue = Color(0xFFE0E7FF);

class AdminSelectPathScreen extends StatefulWidget {
  final bool forManage; // true = update/delete, false = add

  const AdminSelectPathScreen({
    super.key,
    required this.forManage,
  });

  @override
  State<AdminSelectPathScreen> createState() => _AdminSelectPathScreenState();
}

class _AdminSelectPathScreenState extends State<AdminSelectPathScreen> {
  String examType = 'AL';
  String? selectedSubjectId;
  String? selectedLessonId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryBlue,
        title: Text(
          widget.forManage ? 'Manage MCQs' : 'Add MCQs',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepCard(
              title: 'Step 1: Select Exam Type',
              child: DropdownButtonFormField<String>(
                value: examType,
                decoration: const InputDecoration(
                  labelText: 'Exam Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'AL', child: Text('A/L')),
                  DropdownMenuItem(value: 'OL', child: Text('O/L')),
                ],
                onChanged: (value) {
                  setState(() {
                    examType = value!;
                    selectedSubjectId = null;
                    selectedLessonId = null;
                  });
                },
              ),
            ),

            _StepCard(
              title: 'Step 2: Select Subject',
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(examType == 'AL'
                        ? 'AL Subjects'
                        : 'OL Subjects')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  return DropdownButtonFormField<String>(
                    value: selectedSubjectId,
                    hint: const Text('Choose Subject'),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: snapshot.data!.docs.map((doc) {
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(doc['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSubjectId = value;
                        selectedLessonId = null;
                      });
                    },
                  );
                },
              ),
            ),

            if (selectedSubjectId != null)
              _StepCard(
                title: 'Step 3: Select Lesson',
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(examType == 'AL'
                          ? 'AL Subjects'
                          : 'OL Subjects')
                      .doc(selectedSubjectId)
                      .collection('Lessons')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    return DropdownButtonFormField<String>(
                      value: selectedLessonId,
                      hint: const Text('Choose Lesson'),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: snapshot.data!.docs.map((doc) {
                        return DropdownMenuItem(
                          value: doc.id,
                          child: Text(doc['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedLessonId = value);
                      },
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: Icon(widget.forManage
                    ? Icons.edit
                    : Icons.add),
                label: Text(
                  widget.forManage
                      ? 'Manage MCQs'
                      : 'Continue to Add MCQ',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: selectedLessonId == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => widget.forManage
                                ? AdminMCQListScreen(
                                    examType: examType,
                                    subjectId: selectedSubjectId!,
                                    lessonId: selectedLessonId!,
                                  )
                                : AddMcqScreen(
                                    examType: examType,
                                    subjectId: selectedSubjectId!,
                                    lessonId: selectedLessonId!,
                                  ),
                          ),
                        );
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _StepCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: softBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
