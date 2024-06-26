import 'dart:convert';
import 'package:calendar_final/view/group_calendar.dart';
import 'package:calendar_final/view/group_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:calendar_final/view/background.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

int templateId = 108823;

FeedTemplate _getTemplate() {
  String link = 'https://developers.kakao.com';
  return FeedTemplate(
    content: Content(
      title: 'test title',
      description: 'test description',
      imageUrl: Uri.parse('https://example.com/image.png'),
      link: Link(webUrl: Uri.parse(link), mobileWebUrl: Uri.parse(link)),
    ),
    buttons: [
      Button(
        title: 'button title',
        link: Link(
          webUrl: Uri.parse(link),
          mobileWebUrl: Uri.parse(link),
        ),
      ),
    ],
  );
}

Future<void> shareKakaoTalk() async {
  bool isKakaoTalkSharingAvailable = await ShareClient.instance.isKakaoTalkSharingAvailable();

  if (isKakaoTalkSharingAvailable) {
    try {
      Uri uri = await ShareClient.instance.shareCustom(templateId: templateId);
      await ShareClient.instance.launchKakaoTalk(uri);
      print('카카오톡 공유 완료');
    } catch (error) {
      print('카카오톡 공유 실패 $error');
    }
  } else {
    try {
      Uri shareUrl = await WebSharerClient.instance.makeCustomUrl(
          templateId: templateId, templateArgs: {'key1': 'value1'});
      await launch(shareUrl.toString());
    } catch (error) {
      print('카카오톡 공유 실패 $error');
    }
  }
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'HancomMalangMalang',
      ),
      home: LoginPage(),
      initialRoute: '/',
      routes: {
        '/timematching': (context) => GroupCalendar(username: '사용자명'),
        '/detail': (context) => GroupDetailedPage(pin: ''),
      },
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/detail/')) {
          final id = settings.name!.replaceFirst('/detail/', '');
          return MaterialPageRoute(
            builder: (context) => GroupDetailedPage(pin: id),
          );
        }
        return null;
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<bool> _sendRequest(Map<String, dynamic> requestBody) async {
    String lambdaArn = 'https://2ylpznm6rb.execute-api.ap-northeast-2.amazonaws.com/default/master';

    final response = await http.post(
      Uri.parse(lambdaArn),
      body: jsonEncode(requestBody),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['success'];
    } else {
      return false;
    }
  }

  Future<bool> _login(String username, String password) async {
    Map<String, dynamic> requestBody = {
      'function': 'login',
      'id': username,
      'pwd': password,
    };
    return await _sendRequest(requestBody);
  }

  void _handleLogin() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    bool loginSuccess = await _login(username, password);

    if (loginSuccess) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyApp(username: username, password: password),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Login Failed'),
            content: Text('Invalid username or password.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _goToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFb2ddef),
        elevation: 0, // AppBar의 그림자 제거
        actions: [ // 추가된 부분 시작
          IconButton(
            // icon: Image.asset('assets/images/share.png',
            //     width: 20,
            //     height: 20
            // ),
            icon: Icon(Icons.share),
            iconSize: 24,
            onPressed: shareKakaoTalk,
          ),
        ], // 추가된 부분 끝
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFFb2ddef),
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 40.0), // 상단 여백 추가
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    'assets/images/magu_main_logo.png',
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(height: 0), // 로고와 로그인 폼 사이 간격
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: '학번',
                            labelStyle: TextStyle(color: Colors.black), // 글자색 설정
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFb2ddef)), // 밑줄 색깔 설정
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFb2ddef)), // 포커스 시 밑줄 색깔 설정
                            ),
                          ),
                          style: TextStyle(color: Colors.black), // 입력 글자색 설정
                        ),
                        SizedBox(height: 20.0),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: '비밀번호',
                            labelStyle: TextStyle(color: Colors.black), // 글자색 설정
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFb2ddef)), // 밑줄 색깔 설정
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFb2ddef)), // 포커스 시 밑줄 색깔 설정
                            ),
                          ),
                          obscureText: true,
                          style: TextStyle(color: Colors.black), // 입력 글자색 설정
                        ),
                        SizedBox(height: 20.0),
                        ElevatedButton(
                          onPressed: _handleLogin,
                          child: Text('로그인'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFb2ddef), // 버튼 배경색 설정
                            foregroundColor: Colors.black, // 버튼 텍스트 색상 설정
                          ),
                        ),
                        SizedBox(height: 10.0),
                        TextButton(
                          onPressed: _goToSignUp,
                          child: Text('회원가입'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black, // 버튼 텍스트 색 설정
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 500),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _newUsernameController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  Future<bool> _sendRequest(Map<String, dynamic> requestBody) async {
    String lambdaArn = 'https://2ylpznm6rb.execute-api.ap-northeast-2.amazonaws.com/default/master';

    final response = await http.post(
      Uri.parse(lambdaArn),
      body: jsonEncode(requestBody),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['success'];
    } else {
      return false;
    }
  }

  Future<bool> _signUp(String username, String password, String name) async {
    Map<String, dynamic> requestBody = {
      'function': 'signup',
      'id': username,
      'pwd': password,
      'name': name,
    };
    return await _sendRequest(requestBody);
  }

  void _handleSignUp() async {
    String username = _newUsernameController.text;
    String password = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String name = _nameController.text;

    if (password != confirmPassword) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Sign Up Failed'),
            content: Text('Passwords do not match.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    bool signUpSuccess = await _signUp(username, password, name);

    if (signUpSuccess) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Sign Up Failed'),
            content: Text('Failed to create account. Please try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Color(0xFFb2ddef),
      ),
      body: Container(
        color: Color(0xFFb2ddef),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: _newUsernameController,
                  decoration: InputDecoration(
                    labelText: 'ID',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFb2ddef)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFb2ddef)),
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 20.0),
                TextField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFb2ddef)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFb2ddef)),
                    ),
                  ),
                  obscureText: true,
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 20.0),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFb2ddef)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFb2ddef)),
                    ),
                  ),
                  obscureText: true,
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 20.0),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFb2ddef)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFb2ddef)),
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _handleSignUp,
                  child: Text('회원가입'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFb2ddef),
                    foregroundColor: Colors.black,
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

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Color(0xFFb2ddef),
      ),
      body: Center(
        child: Text(
          'Hello World',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
