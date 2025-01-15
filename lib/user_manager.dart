// user_manager.dart
class UserManager {
  // 싱글톤 인스턴스를 저장할 private 정적 변수
  static final UserManager _instance = UserManager._internal();

  // 팩토리 생성자를 통해 항상 동일한 인스턴스를 반환
  factory UserManager() {
    return _instance;
  }

  // 내부적으로만 사용할 수 있는 private 생성자
  UserManager._internal();

  // 유저 아이디를 저장할 변수
  int userId = 0;

  // 유저 아이디를 설정하는 메서드
  void setUserId(int id) {
    userId = id;
  }

  // 유저 아이디를 가져오는 메서드
  int getUserId() {
    return userId;
  }
}