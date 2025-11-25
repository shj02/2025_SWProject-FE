package com.Mogle.MogleTrip.sw_project_fe

import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.util.Base64
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import java.security.MessageDigest

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        printKeyHash()   // 🔑 앱 실행 시 키 해시 출력
    }

    private fun printKeyHash() {
        try {
            val info = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageManager.getPackageInfo(
                    packageName,
                    PackageManager.GET_SIGNING_CERTIFICATES
                )
            } else {
                @Suppress("DEPRECATION")
                packageManager.getPackageInfo(
                    packageName,
                    PackageManager.GET_SIGNATURES
                )
            }

            // ✅ null-safe 하게 서명 배열 가져오기
            val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                info.signingInfo?.apkContentsSigners ?: emptyArray()
            } else {
                @Suppress("DEPRECATION")
                info.signatures ?: emptyArray()
            }

            for (signature in signatures) {
                val md = MessageDigest.getInstance("SHA")
                md.update(signature.toByteArray())
                val keyHash = String(Base64.encode(md.digest(), Base64.NO_WRAP))
                Log.d("KAKAO_KEY_HASH", "keyHash: $keyHash")
            }
        } catch (e: Exception) {
            Log.e("KAKAO_KEY_HASH", "Error while getting key hash", e)
        }
    }
}
