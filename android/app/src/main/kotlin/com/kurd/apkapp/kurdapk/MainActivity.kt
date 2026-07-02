package com.kurd.apkapp.kurdapk

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.InputStreamReader

class MainActivity: FlutterActivity() {
    private val CHANNEL = "kurdapk/shell"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "runCommand" -> {
                    val cmd = call.argument<String>("cmd") ?: "echo no command"
                    try {
                        val process = ProcessBuilder("/system/bin/sh", "-c", cmd)
                            .redirectErrorStream(true)
                            .start()
                        val output = BufferedReader(InputStreamReader(process.inputStream)).readText()
                        process.waitFor()
                        result.success(output)
                    } catch (e: Exception) {
                        result.error("SHELL_ERROR", e.message, null)
                    }
                }
                "getNativeLibraryDir" -> {
                    result.success(applicationInfo.nativeLibraryDir)
                }
                "getFilesDir" -> {
                    result.success(filesDir.absolutePath)
                }
                else -> result.notImplemented()
            }
        }
    }
}
