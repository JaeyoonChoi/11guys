import 'package:flutter/material.dart';
import 'package:calendar_final/view/login.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(
    nativeAppKey: '9886dada6ce2792d4083622cdaa47e66', // 네이티브 앱 키
    javaScriptAppKey: '43e0ad6969d6372d76240067769e3e09', // 자바스크립트 앱 키
  );
  runApp(LoginApp());
}
