import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMcqScreen extends StatefulWidget {
  final String examType;
  final String subjectId;
  final String lessonId;
  final DocumentSnapshot? existingMcq;

  const AddMcqScreen({
    super.key,
    required this.examType,
    required this.subjectId,
    required this.lessonId,
    this.existingMcq,
  });

  @override
  State<AddMcqScreen> createState() => _AddMcqScreenState();
}


class _AddMcqScreenState extends State<AddMcqScreen> {
late String examType;
late String selectedSubjectId;
late String selectedLessonId;

@override
void initState() {
  super.initState();

  examType = widget.examType;
  selectedSubjectId = widget.subjectId;
  selectedLessonId = widget.lessonId;

  if (widget.existingMcq != null) {
    final data = widget.existingMcq!.data() as Map<String, dynamic>;

    questionController.text = data['questionText'] ?? '';
    yearController.text = data['year'].toString();

    final List options = data['options'] ?? [];
    for (int i = 0; i < options.length && i < optionControllers.length; i++) {
      optionControllers[i].text = options[i];
    }

    correctOptionIndex = data['correctOptionIndex'];
  }
}


  final questionController = TextEditingController();
  final yearController = TextEditingController();

  final List<TextEditingController> optionControllers =
      List.generate(5, (_) => TextEditingController());

  int? correctOptionIndex;
  bool loading = false;

Future<void> saveMcq() async {
  if (widget.subjectId == null ||
      widget.lessonId == null ||
      correctOptionIndex == null ||
      questionController.text.isEmpty ||
      yearController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all fields')),
    );
    return;
  }

  setState(() => loading = true);

// 1️⃣ DATA OBJECT
final mcqData = {
  'questionText': questionController.text.trim(),
  'options': optionControllers.map((c) => c.text.trim()).toList(),
  'correctOptionIndex': correctOptionIndex,
  'year': int.parse(yearController.text),
  'examType': widget.examType,
};

// 2️⃣ COLLECTION REFERENCE
final collectionRef = FirebaseFirestore.instance
    .collection(widget.examType == 'AL'
        ? 'AL Subjects'
        : 'OL Subjects')
    .doc(widget.subjectId)
    .collection('Lessons')
    .doc(widget.lessonId)
    .collection('MCQs');

// 3️⃣ ADD or UPDATE
if (widget.existingMcq == null) {
  await collectionRef.add(mcqData);
} else {
  await widget.existingMcq!.reference.update(mcqData);
}

  setState(() => loading = false);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('MCQ saved successfully')),
  );

  Navigator.pop(context);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add MCQ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
  value: widget.examType,
  decoration: const InputDecoration(labelText: 'Exam Type'),
  items: const [
    DropdownMenuItem(value: 'AL', child: Text('A/L')),
    DropdownMenuItem(value: 'OL', child: Text('O/L')),
  ],
  onChanged: (value) {
    setState(() {
    });
  },
),

            /// SUBJECT DROPDOWN
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
    .collection(widget.examType == 'AL' ? 'AL Subjects' : 'OL Subjects')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                return DropdownButtonFormField<String>(
                  value: widget.subjectId,
                  hint: const Text('Select Subject'),
                  items: snapshot.data!.docs.map((doc) {
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(doc['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            /// LESSON DROPDOWN
            if (widget.subjectId != null)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(widget.examType == 'AL' ? 'AL Subjects' : 'OL Subjects')
                    .doc(widget.subjectId)
                    .collection('Lessons')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  return DropdownButtonFormField<String>(
                    value: widget.lessonId,
                    hint: const Text('Select Lesson'),
                    items: snapshot.data!.docs.map((doc) {
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(doc['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                    },
                  );
                },
              ),

            const SizedBox(height: 16),

            /// QUESTION
            TextField(
              controller: questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            /// YEAR
            TextField(
              controller: yearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Year',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            /// OPTIONS
            ...List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: optionControllers[index],
                  decoration: InputDecoration(
                    labelText: 'Option ${index + 1}',
                    border: const OutlineInputBorder(),
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            /// CORRECT OPTION
            DropdownButtonFormField<int>(
              value: correctOptionIndex,
              hint: const Text('Correct Option Index'),
              items: List.generate(5, (i) {
                return DropdownMenuItem(
                  value: i,
                  child: Text('Option ${i + 1}'),
                );
              }),
              onChanged: (value) {
                setState(() => correctOptionIndex = value);
              },
            ),

            const SizedBox(height: 24),

            /// SAVE BUTTON
            ElevatedButton(
              onPressed: loading ? null : saveMcq,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Save MCQ'),
            ),
          ],
        ),
      ),
    );
  }
}
