import 'package:flutter/material.dart';

class TextButtonTopIcon extends StatelessWidget {
  final IconData icon;
  final String title;
  final Function()? onPress;

  const TextButtonTopIcon({required this.icon, this.title = '', this.onPress, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextButton(
          onPressed: onPress,
          style: TextButton.styleFrom(fixedSize: const Size(100, 72), side: const BorderSide(color: Colors.green, width: 1)),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 15, 10, 10),
                child: Icon(icon, size: 24),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 13),
              )
            ],
          ),
        ),
      ],
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
        style: TextButton.styleFrom(fixedSize: const Size(120, 40), backgroundColor: Colors.green, elevation: 3),
        child: Text(
          title,
          style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
