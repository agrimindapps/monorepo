import 'package:flutter/material.dart';

class AppBars extends AppBar {
  AppBars({
    title = '',
    String? subtitle,
    List<Widget> actions = const <Widget>[],
    bool leading = false,
    super.key,
  }) : super(
          automaticallyImplyLeading: leading,
          title: Padding(
            padding: EdgeInsets.fromLTRB(
                0, 0, leading && actions.isEmpty ? 56 : 0, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    title,
                    maxLines: 1,
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 18),
                  ),
                ),
                if (subtitle != null)
                  Center(
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 14),
                    ),
                  )
                else
                  Container()
              ],
            ),
          ),
          actions: actions,
          centerTitle: true,
          elevation: 3,
        );
}
