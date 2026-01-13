import 'package:flutter/material.dart';
import '../models/mcq.dart';

class QuestionScreen extends StatefulWidget {
  final McqModel mcq;

  const QuestionScreen({
    super.key,
    required this.mcq,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}
class _QuestionScreenState extends State<QuestionScreen> {
  int? selectedIndex;
  bool answered = false;

  @override
  Widget build(BuildContext context) {
    final mcq = widget.mcq;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
Text(
  mcq.questionText,
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 8),

Text(
  'Year: ${mcq.year}',
  style: const TextStyle(color: Colors.grey),
),

const SizedBox(height: 20),
...List.generate(mcq.options.length, (index) {
  Color bgColor = Colors.transparent;

  if (answered) {
    if (index == mcq.correctOptionIndex) {
      bgColor = Colors.green.withOpacity(0.2);
    } else if (index == selectedIndex) {
      bgColor = Colors.red.withOpacity(0.2);
    }
  }

  return GestureDetector(
    onTap: answered
        ? null
        : () {
            setState(() {
              selectedIndex = index;
              answered = true;
            });
          },
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(mcq.options[index]),
    ),
  );
}),
if (answered) ...[
  const SizedBox(height: 16),
  Text(
    'Correct Answer: ${mcq.options[mcq.correctOptionIndex]}',
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.green,
    ),
  ),
],
          ],
        ),
      ),
    );
  }
}
