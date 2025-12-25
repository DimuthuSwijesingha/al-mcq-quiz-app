import 'package:flutter/material.dart';
import '../models/mcq.dart';

class McqCard extends StatefulWidget {
  final McqModel mcq;

  const McqCard({super.key, required this.mcq});

  @override
  State<McqCard> createState() => _McqCardState();
}

class _McqCardState extends State<McqCard> {
  int? selectedOptionIndex; // which option user tapped
  Set<int> disabledOptions = {}; // wrong options user tried
bool isAnsweredCorrectly = false;


  @override
  Widget build(BuildContext context) {
    final mcq = widget.mcq;

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question text
            Text(
              mcq.questionText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Options
            Column(
              children: List.generate(mcq.options.length, (index) {
                return GestureDetector(
                  onTap: () {
                    if (isAnsweredCorrectly || disabledOptions.contains(index)) {
                      return; // Do nothing if already answered correctly or option is disabled
                    }

                    setState(() {
                      selectedOptionIndex = index;

                      if (index == mcq.correctOptionIndex) {
                        // Correct answer
                        isAnsweredCorrectly = true;
                      } else {
                        // Wrong answer
                        disabledOptions.add(index);
                      }
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                       color: (isAnsweredCorrectly &&
                       index == widget.mcq.correctOptionIndex)
                        ? Colors.green.withAlpha(51)
                        : disabledOptions.contains(index)
                        ? Colors.red.withAlpha(51)
                        : Colors.transparent,
                        border: Border.all(color: Colors.grey),
                         borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(mcq.options[index]),
                  ),
                );
              }),
            ),

if (isAnsweredCorrectly)
  const Padding(
    padding: EdgeInsets.only(top: 8),
    child: Text(
      "✓ Correct answer",
      style: TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    ),
  )
else if (disabledOptions.isNotEmpty)
  const Padding(
    padding: EdgeInsets.only(top: 8),
    child: Text(
      "✗ Try again",
      style: TextStyle(color: Colors.red),
    ),
  ),
            
            const SizedBox(height: 8),

            Text(
              'Year: ${mcq.year}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
