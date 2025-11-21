import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'auth_api.dart'; // 백엔드 통신을 위한 AuthService
import 'user_service.dart'; // 사용자 정보 저장을 위한 UserService

class KakaoLoginService {
  Future<LoginResponse> login() async {
    kakao.OAuthToken token;

    // 카카오톡 설치 여부에 따라 로그인 방식 분기
    if (await kakao.isKakaoTalkInstalled()) {
      try {
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
      } catch (_) {
        // 사용자가 카카오톡에서 로그인을 취소한 경우 등 에러 발생 시
        // 카카오 계정으로 로그인 시도
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }
    } else {
      // 카카오톡이 설치되어 있지 않은 경우
      token = await kakao.UserApi.instance.loginWithKakaoAccount();
    }

    // 1. 발급받은 카카오 액세스 토큰을 우리 서버로 보내서 JWT와 사용자 정보 받기
    final result = await AuthService().loginWithKakao(token.accessToken);

    // 2. 받은 JWT와 userId를 UserService에 저장 (회원가입 과정에서 사용)
    UserService().setAuthToken(result.token);
    UserService().setUserId(result.userId);

    // 3. 로그인 결과를 화면(LoginScreen)으로 반환
    return result;
  }
}
