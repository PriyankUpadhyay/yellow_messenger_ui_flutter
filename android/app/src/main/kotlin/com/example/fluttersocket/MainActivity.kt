package com.example.fluttersocket


import android.os.Bundle
import android.util.Log

import java.util.concurrent.TimeUnit

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugins.GeneratedPluginRegistrant
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable



class MainActivity : FlutterActivity() {

  private var timerSubscription: Disposable? = null

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
      EventChannel(flutterView, STREAM).setStreamHandler(
             object : StreamHandler{
                 override fun onListen(p0: Any?, p1: EventChannel.EventSink?) {
                     io.flutter.Log.w(TAG, "Stream Connected")
                     Observable
                             .interval(0, 1, TimeUnit.SECONDS)
                             .observeOn(AndroidSchedulers.mainThread())
                             .subscribe(
                                     { timer: Long ->
                                         Log.w(TAG, "emitting timer event $timer")
                                         p1?.success(timer)
                                     },
                                     { error: Throwable ->
                                         Log.e(TAG, "error in emitting timer", error)
                                         p1?.error("STREAM", "Error in processing observable", error.message)
                                     },
                                     { Log.w(TAG, "closing the timer observable") }
                             )


                 }

                 override fun onCancel(p0: Any?) {
                     io.flutter.Log.w(TAG, "Stream Disconnected")
                 }

             }
      )
  }

  companion object {

    val TAG = "eventchannelsample"
    val STREAM = "com.yellowmessenger.bot/stream"
  }
}