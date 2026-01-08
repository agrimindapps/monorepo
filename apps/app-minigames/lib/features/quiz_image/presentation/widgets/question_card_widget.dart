import 'package:flutter/material.dart';
import '../../domain/entities/quiz_question.dart';

/// Widget that displays the quiz question with image or emoji
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
            // Question image or emoji
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImageContent(),
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

  Widget _buildImageContent() {
    // Check if it's an emoji URL (format: "emoji:🇧🇷")
    if (question.imageUrl.startsWith('emoji:')) {
      final emoji = question.imageUrl.substring(6); // Remove "emoji:" prefix
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 100),
          ),
        ),
      );
    }

    // Network image with loading and error handling
    return Image.network(
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
        // Fallback to question mark emoji on error
        return Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🏳️', style: TextStyle(fontSize: 60)),
                SizedBox(height: 8),
                Text(
                  'Imagem indisponível',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
