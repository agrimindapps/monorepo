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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2A2D3E),
                  const Color(0xFF1F2230),
                ],
              )
            : null,
        color: isDark ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark
            ? Border.all(
                color: const Color(0xFF3F51B5).withValues(alpha: 0.3),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF3F51B5).withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: isDark ? 16 : 8,
            offset: const Offset(0, 4),
            spreadRadius: isDark ? 2 : 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Question image or emoji
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImageContent(isDark),
            ),
            const SizedBox(height: 20),

            // Question text
            Text(
              question.question,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent(bool isDark) {
    // Check if it's an emoji URL (format: "emoji:🇧🇷")
    if (question.imageUrl.startsWith('emoji:')) {
      final emoji = question.imageUrl.substring(6); // Remove "emoji:" prefix
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1D2E) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: isDark
              ? Border.all(
                  color: const Color(0xFF3F51B5).withValues(alpha: 0.2),
                )
              : null,
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
