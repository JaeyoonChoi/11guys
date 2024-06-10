import 'dart:convert';
import 'package:calendar_final/view/group_calendar.dart';
import 'package:calendar_final/view/group_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:calendar_final/view/background.dart';

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'HancomMalangMalang', // 글자체 설정
      ),
      home: LoginPage(),

      // routing
      initialRoute: '/',  // 초기 경로 설정
      routes: {
        '/timematching': (context) => GroupCalendar(username: '사용자명'),
        '/detail': (context) => GroupDetailedPage(pin: ''),  // '/' 경로에 HomePage 위젯을 연결합니다.
        // '/timematching': (context) => GroupCalendar(username: '사용자명',),
      },
      onGenerateRoute: (settings) {
        // 동적 경로를 처리하기 위한 설정
        if (settings.name != null && settings.name!.startsWith('/detail/')) {
          final id = settings.name!.replaceFirst('/detail/', '');  // '/detail/' 뒤의 ID를 추출
          return MaterialPageRoute(
            builder: (context) => GroupDetailedPage(pin: id),  //추출한 ID를 사용하여 GroupDetailPage 위젯 생성
          );
        }
        return null;  // 처리할 수 없는 경로는 null읇 반환
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
          builder: (context) => MyApp(username: username, password: password),  // 전달
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

  // 회원가입 창
  void _goToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }

// 디자인
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFb2ddef),
        elevation: 0,  // AppBar의 그림자 제거
      ),
      body: SingleChildScrollView(
        child: Container(
        color: Color(0xFFb2ddef),
        child: Align(
          alignment: Alignment.topCenter, //
          child: Padding(
            padding: EdgeInsets.only(top: 40.0),  // 상단 여백 추가
            child: Column(// 로고
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'assets/images/magu_main_logo.png',
                width: 200,
                height:200,
              ),
              SizedBox(height: 0),  // 로고와 로그인 폼 사이 간격

              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                // height: 0,
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
            ]
          ),
          ),
        ),
      ),
      ),
    );
  }
}

class SignUpPage extends StatelessWidget {
  TextEditingController _newUsernameController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  // TextEditingController _emailController = TextEditingController();

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

  void _signUp() async {
    // 여기에 회원 가입 처리 로직 추가
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
                    labelText: 'New Username',
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
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
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
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
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
                // TextField(
                //   controller: _emailController,
                //   decoration: InputDecoration(
                //     labelText: 'Email',
                //     labelStyle: TextStyle(color: Colors.black), // 글자색 설정
                //     enabledBorder: UnderlineInputBorder(
                //       borderSide: BorderSide(color: Color(0xFFb2ddef)), // 밑줄 색깔 설정
                //     ),
                //     focusedBorder: UnderlineInputBorder(
                //       borderSide: BorderSide(color: Color(0xFFb2ddef)), // 포커스 시 밑줄 색깔 설정
                //     ),
                //   ),
                //   style: TextStyle(color: Colors.black), // 입력 글자색 설정
                // ),
                // SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _signUp,
                  child: Text('회원가입'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFb2ddef), // 버튼 배경색 설정
                    foregroundColor: Colors.black, // 버튼 텍스트 색상 설정
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



// 람다 연결

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
