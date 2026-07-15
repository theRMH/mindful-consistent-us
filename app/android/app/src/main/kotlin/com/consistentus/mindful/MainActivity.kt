package com.consistentus.mindful

import android.content.Intent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.consistentus/cast").setMethodCallHandler { call, result ->
      if (call.method == "openCastSettings") {
        startActivity(Intent("android.settings.CAST_SETTINGS"))
        result.success(null)
      } else {
        result.notImplemented()
      }
    }
  }
}
