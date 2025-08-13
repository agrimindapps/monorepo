// Flutter imports:
import 'package:flutter/material.dart';

class TextButtonTopIcon extends StatelessWidget {
  const TextButtonTopIcon({
    this.icon = Icons.abc,
    this.title = '',
    this.iconText = '',
    this.onPress,
    this.width = 110,
    this.height = 74,
    super.key,
    this.color = Colors.green,
  });

  final String title;
  final IconData? icon;
  final String iconText;
  final double width;
  final double height;
  final Color color;
  final Function()? onPress;

  @override
  Widget build(BuildContext context) {
    // Obtém o tema atual para suportar modos claro e escuro
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define cores com base no tema
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color secondaryColor = isDarkMode
        ? HSLColor.fromColor(primaryColor).withLightness(0.25).toColor()
        : HSLColor.fromColor(primaryColor).withLightness(0.85).toColor();

    // Cores para o texto com bom contraste
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color countColor = isDarkMode ? Colors.white : primaryColor;

    // Efeito de sombra para dar profundidade
    final List<BoxShadow> buttonShadow = isDarkMode
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ];

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: InkWell(
        onTap: onPress,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: buttonShadow,
          ),
          child: Container(
            width: width,
            height: height,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconText == '')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Icon(icon, size: 21, color: textColor),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.black26
                            : Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        iconText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: countColor,
                        ),
                      ),
                    ),
                  ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VTextButtom extends StatelessWidget {
  const VTextButtom({this.title = '', this.onPress, super.key});

  final String title;
  final Function()? onPress;

  @override
  Widget build(BuildContext context) {
    // Obtém o tema atual para suportar modos claro e escuro
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define cores com base no tema
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color secondaryColor = isDarkMode
        ? HSLColor.fromColor(primaryColor).withLightness(0.25).toColor()
        : HSLColor.fromColor(primaryColor).withLightness(0.85).toColor();

    // Cor para o texto com bom contraste
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 5),
      child: InkWell(
        onTap: onPress,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.1),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
