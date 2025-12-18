import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'login_page_mobile.dart';
import 'login_page_web.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const LoginPageWeb();
    } else {
      return const LoginPageMobile();
    }
  }
}
