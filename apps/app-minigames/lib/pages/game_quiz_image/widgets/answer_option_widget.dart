// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';

class AnswerOptionWidget extends StatelessWidget {
  final String text;
  final int index;
  final AnswerState state;
  final bool isCorrect;
  final VoidCallback onTap;

  const AnswerOptionWidget({
    super.key,
    required this.text,
    required this.index,
    required this.state,
    required this.isCorrect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: InkWell(
        onTap: state == AnswerState.unanswered ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Letra da opção (A, B, C, etc)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getBorderColor(),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, etc.
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getBorderColor(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Texto da opção
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Ícone (apenas para estados de respondido)
              if (state != AnswerState.unanswered && state.icon != null)
                Icon(
                  state.icon,
                  color:
                      state == AnswerState.correct ? Colors.green : Colors.red,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    // Se a resposta ainda não foi selecionada
    if (state == AnswerState.unanswered) {
      return Colors.white;
    }

    // Se esta é a resposta correta, ou a resposta incorreta selecionada
    return state.color;
  }

  Color _getBorderColor() {
    // Se a resposta ainda não foi selecionada
    if (state == AnswerState.unanswered) {
      return Colors.blue.shade300;
    }

    // Se esta opção é a correta
    if (isCorrect) {
      return Colors.green;
    }

    // Se esta opção é incorreta e foi selecionada
    if (state == AnswerState.incorrect) {
      return Colors.red;
    }

    // Se esta opção não foi selecionada
    return Colors.grey;
  }
}
