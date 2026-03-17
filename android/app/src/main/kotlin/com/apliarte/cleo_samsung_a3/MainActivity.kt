package com.apliarte.cleo_samsung_a3

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.aplibot/termux"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "runCommand" -> {
                        val path = call.argument<String>("path")
                            ?: "/data/data/com.termux/files/usr/bin/bash"
                        val args = call.argument<List<String>>("args") ?: emptyList()
                        val background = call.argument<Boolean>("background") ?: true

                        try {
                            val intent = Intent().apply {
                                setClassName(
                                    "com.termux",
                                    "com.termux.app.RunCommandService"
                                )
                                action = "com.termux.RUN_COMMAND"
                                putExtra(
                                    "com.termux.RUN_COMMAND_PATH",
                                    path
                                )
                                putExtra(
                                    "com.termux.RUN_COMMAND_ARGUMENTS",
                                    args.toTypedArray()
                                )
                                putExtra(
                                    "com.termux.RUN_COMMAND_BACKGROUND",
                                    background
                                )
                            }
                            startService(intent)
                            result.success("OK")
                        } catch (e: Exception) {
                            result.error("TERMUX_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
