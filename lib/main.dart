import 'package:flutter/material.dart';
import 'bottom_navigation_screen.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_manager.dart';

void main() {
  // 1) Kakao SDK 초기화 (네이티브 앱 키)
  KakaoSdk.init(nativeAppKey: '1bd3eaa8a3ca19f6e3c34bfdccae8e11');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Screen with Gradient',
      home: SplashScreen(),
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final bool _isPressed = false;
  String _status = '로그인 준비 중...';

  // 카카오톡 로그인 함수
  Future<void> _loginWithKakao() async {
    // 진행 상태를 보여주는 다이얼로그 표시
    _showProgressDialog();

    try {
      // 2) 카카오톡 설치 여부 확인 후 카카오 로그인 시도
      print('Checking if KakaoTalk is installed...'); // debug

      bool isKakaoInstalled = await isKakaoTalkInstalled();
      OAuthToken token;

      if (isKakaoInstalled) {
        print('KakaoTalk is installed. Logging in with KakaoTalk...'); // debug
        setState(() {_status = '카카오톡으로 로그인 중...';});

        final keyHash = await KakaoSdk.origin; // android key hash
        print('key Hash: $keyHash');

        token = await UserApi.instance.loginWithKakaoTalk();
        print('token is successfully generated'); // debug
      } else {
        print('KakaoTalk is not installed. Logging in with Kakao Account...'); // debug
        setState(() {_status = '카카오 계정으로 로그인 중...';});
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      final accessToken = token.accessToken;
      print('Kakao Login successful. Access Token: $accessToken'); // debug

      // 3) 서버에 토큰 전달
      print('Sending token to server...'); // debug
      final loginSuccess = await _sendTokenToServer(accessToken);

      if (loginSuccess) {
        // 4) 로그인 성공 시 다음 페이지로 전환
        print('Server verification successful. Navigating to SuccessScreen...'); // debug
        setState(() {_status = '로그인 성공! 🎉';});

        Future.delayed(Duration(seconds: 3), () {  // 대기 시간은 적절히 조절
          if (!mounted) return;
          Navigator.of(context).pop(); // 다이얼로그 닫기
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BottomNavigationScreen(),),
          );
        });
      } else {
        print('Server verification failed.'); // debug
        setState(() { _status = '서버 검증 실패. 다시 시도해주세요.';});
        Future.delayed(Duration(seconds: 3), () {
          Navigator.of(context).pop(); // 다이얼로그 닫기
        });
      }
    } catch (error) {
      print('Kakao login failed: $error'); // debug
      setState(() {
        _status = '카카오 로그인 실패 ㅠㅠ: $error';
      });
      Future.delayed(Duration(seconds: 3), () {
        Navigator.of(context).pop(); // 다이얼로그 닫기
      });
    }
  }

  // 서버 전달자
  Future<bool> _sendTokenToServer(String accessToken) async {
    try {
      // 예시: NAT IP (172.10.7.22:80)으로 POST
      final url = Uri.parse('http://172.10.7.22:3000/auth/kakao');
      print('Sending POST request to $url with access token...'); // debug
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'accessToken': accessToken}),
      );

      // 응답 상태 출력
      print('Server response: ${response.statusCode}'); // debug
      print('Server response body: ${response.body}, ${response.body.runtimeType}'); // debug

      if (response.statusCode == 200) {
        // 서버에서 회원가입/로그인 로직 후 JSON 반환
        // JSON 형식으로 응답 바디를 디코딩
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // responseData에서 userID 추출
        int userID = responseData['userId'];

        if (userID != null) {
          // 사용자 ID를 전역 UserManager에 저장
          UserManager userManager = UserManager();
          userManager.setUserId(userID);
          return true;

        } else {
          print('userID not found in response');
          return false;
        }
      } else {
        print('서버 응답 오류: ${response.statusCode} / ${response.body}');
        return false;
      }
    } catch (e) {
      print('서버 통신 에러: $e');
      return false;
    }
  }

  // 다이얼로그 표시자
  void _showProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 다이얼로그 외부를 눌러도 닫히지 않도록 설정
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Text(
                      _status, // 현재 상태를 표시
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0E0517), // Dark purple
              Color(0xFF4C1B7D), // Lighter purple
            ],
          ),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding:
                const EdgeInsets.only(top: 230), // Adjust the padding as needed
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Galano',
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Echoes of\n',
                          style: TextStyle(color: Color(0xFFD992FF)),
                        ),
                        TextSpan(
                          text: 'Tomorrow',
                          style: TextStyle(color: Colors.white),
                        )
                      ]),
                ),
                SizedBox(height: 200), // Adjust space between text and buttons
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BottomNavigationScreen()),
                    );
                  },
                  child: Container(
                    width: 320,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage('assets/images/button1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Get started',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'AgeoPersonalUse',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loginWithKakao,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF130529),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    minimumSize: Size(320, 30),
                  ),
                  child: Text(
                    'Start with Kakao',
                    style:
                        TextStyle(fontSize: 18, fontFamily: 'AgeoPersonalUse'),
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
