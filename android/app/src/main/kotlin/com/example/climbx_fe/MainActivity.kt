package com.example.climbx_fe

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    // 생성된 FlutterEngine을 보관할 변수
    private lateinit var engineRef: FlutterEngine

    // FlutterEngine이 생성된 직후에 호출되는 메소드
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        engineRef = flutterEngine
    }

    override fun onDestroy() {
        super.onDestroy()
        // 엔진을 직접 파괴해서 내부 LocalizationPlugin 등도 같이 해제
        engineRef.destroy()
    }
}
