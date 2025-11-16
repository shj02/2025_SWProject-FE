import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'auth_api.dart'; // 네가 만든 백엔드 호출용 AuthApi

class KakaoLoginService {
  Future<LoginResponse> login() async {
    kakao.OAuthToken token;

    if (await kakao.isKakaoTalkInstalled()) {
      try {
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
      } catch (_) {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }
    } else {
      token = await kakao.UserApi.instance.loginWithKakaoAccount();
    }

    // 카카오 accessToken을 우리 서버로 보내기
    final result = await AuthApi.loginWithKakao(token.accessToken);

    // TODO: result.token (JWT)을 secure storage 등에 저장
    return result;
  }
}
