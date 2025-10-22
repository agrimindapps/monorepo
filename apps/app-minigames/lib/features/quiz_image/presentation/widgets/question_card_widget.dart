import 'package:flutter/material.dart';
import '../../domain/entities/quiz_question.dart';

/// Widget that displays the quiz question with image
class QuestionCardWidget extends StatelessWidget {
  final QuizQuestion question;

  const QuestionCardWidget({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Question image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                question.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Question text
            Text(
              question.question,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
