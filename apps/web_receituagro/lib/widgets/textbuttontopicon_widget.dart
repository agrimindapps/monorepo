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
  });

  final String title;
  final IconData? icon;
  final String iconText;
  final double width;
  final double height;
  final Function()? onPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: TextButton(
        onPressed: onPress,
        clipBehavior: Clip.antiAlias,
        style: TextButton.styleFrom(
          fixedSize: Size(width, height),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Column(
          children: [
            if (iconText == '')
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 7, 10, 0),
                child: Icon(icon, size: 21),
              )
            else
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 7, 10, 0),
                child: Text(iconText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
            )
          ],
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
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 5),
      child: TextButton(
        onPressed: onPress,
        child: Text(
          title,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
        ),
      ),
    );
  }
}
