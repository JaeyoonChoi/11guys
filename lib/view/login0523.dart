import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:calendar_final/view/main.dart';

void main() {
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
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
        // MaterialPageRoute(builder: (context) => HomePage()),
        MaterialPageRoute(builder: (context) => MyApp()),
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
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _handleLogin,
              child: Text('Sign In'),
            ),
            SizedBox(height: 10.0),
            TextButton(
              onPressed: _goToSignUp,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpPage extends StatelessWidget {
  TextEditingController _newUsernameController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

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
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _newUsernameController,
              decoration: InputDecoration(labelText: 'New Username'),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _signUp,
              child: Text('Sign Up'),
            ),
          ],
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