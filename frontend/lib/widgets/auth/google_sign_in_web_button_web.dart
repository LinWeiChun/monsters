import 'package:flutter/widgets.dart';
import 'package:google_sign_in_web/web_only.dart' as google_sign_in_web;

class GoogleSignInWebButton extends StatelessWidget {
  const GoogleSignInWebButton({super.key});

  @override
  Widget build(BuildContext context) {
    return google_sign_in_web.renderButton();
  }
}
