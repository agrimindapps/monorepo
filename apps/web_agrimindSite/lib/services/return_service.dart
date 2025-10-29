import 'package:flutter/material.dart';

class ReturnService {
  late BuildContext context;

  void setContext(BuildContext context) {
    this.context = context;
  }

  void pressPop() {
    Navigator.of(context).pop();
  }
}

final returnScope = ReturnService();
