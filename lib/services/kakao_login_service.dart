import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'auth_api.dart'; 

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

    return await AuthService().loginWithKakao(token.accessToken);
  }
}
