package com.example.hairstylr

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "hairstylr/phone"
        ).setMethodCallHandler { call, result ->
            if (call.method != "dial") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val phoneNumber = call.argument<String>("phoneNumber").orEmpty()
            if (phoneNumber.isBlank()) {
                result.success(false)
                return@setMethodCallHandler
            }

            val intent = Intent(Intent.ACTION_DIAL).apply {
                data = Uri.parse("tel:$phoneNumber")
            }

            if (intent.resolveActivity(packageManager) == null) {
                result.success(false)
                return@setMethodCallHandler
            }

            startActivity(intent)
            result.success(true)
        }
    }
}
