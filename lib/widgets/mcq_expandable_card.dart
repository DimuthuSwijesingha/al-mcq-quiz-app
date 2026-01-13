import 'package:flutter/material.dart';
import '../models/mcq.dart';

const Color primaryBlue = Color(0xFF1E3A8A);
const Color correctGreen = Color(0xFF16A34A);
const Color wrongRed = Color(0xFFDC2626);
const Color softGray = Color(0xFFF1F5F9);

class McqExpandableCard extends StatefulWidget {
  final McqModel mcq;

  const McqExpandableCard({
    super.key,
    required this.mcq,
  });

  @override
  State<McqExpandableCard> createState() => _McqExpandableCardState();
}

class _McqExpandableCardState extends State<McqExpandableCard> {
  bool expanded = false;
  final Set<int> wrongSelected = {};
  int? correctSelected;

  @override
  Widget build(BuildContext context) {
    final mcq = widget.mcq;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// QUESTION HEADER
            GestureDetector(
              onTap: () {
                setState(() {
                  expanded = !expanded;
                });
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mcq.questionText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Year: ${mcq.year}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: primaryBlue,
                  ),
                ],
              ),
            ),

            /// ANSWERS
            if (expanded) ...[
              const SizedBox(height: 16),

              ...List.generate(mcq.options.length, (index) {
                bool isWrong = wrongSelected.contains(index);
                bool isCorrect = correctSelected == index;

                Color bgColor = softGray;
                Color borderColor = Colors.transparent;
                Color textColor = Colors.black;

                if (isWrong) {
                  bgColor = wrongRed.withOpacity(0.15);
                  borderColor = wrongRed;
                  textColor = wrongRed;
                }

                if (isCorrect) {
                  bgColor = correctGreen.withOpacity(0.15);
                  borderColor = correctGreen;
                  textColor = correctGreen;
                }

                return GestureDetector(
                  onTap: correctSelected != null
                      ? null
                      : () {
                          setState(() {
                            if (index == mcq.correctOptionIndex) {
                              correctSelected = index;
                            } else {
                              wrongSelected.add(index);
                            }
                          });
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Text(
                          String.fromCharCode(65 + index) + '. ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            mcq.options[index],
                            style: TextStyle(
                              fontSize: 15,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              /// CORRECT ANSWER TEXT
              if (correctSelected != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: correctGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Correct answer: ${mcq.options[mcq.correctOptionIndex]}',
                        style: const TextStyle(
                          color: correctGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ]
            ],
          ],
        ),
      ),
    );
  }
}
