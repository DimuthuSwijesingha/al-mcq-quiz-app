class McqModel {
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String? imageUrl;
  final int year;

  McqModel({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.year,
    this.imageUrl,
  });

 factory McqModel.fromFirestore(Map<String, dynamic> data) {
  return McqModel(
    questionText: data['questionText'] ?? '',
    options: List<String>.from(data['options'] ?? []),
    correctOptionIndex: data['correctOptionIndex'] ?? 0,
    year: data['year'] ?? 0,
    imageUrl: data['imageUrl'], // already nullable
  );
}

}
