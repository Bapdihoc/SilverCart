package com.example.silvercart

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import android.media.MediaRecorder
import android.media.AudioRecord
import android.media.AudioFormat
import android.media.AudioManager
import android.os.Handler
import android.os.Looper
import java.nio.ByteBuffer
import java.nio.ByteOrder

class MainActivity: FlutterActivity() {
    private val CHANNEL = "microphone_channel"
    private val AUDIO_CHANNEL = "audio_data_channel"
    
    private var audioRecord: AudioRecord? = null
    private var isRecording = false
    private var audioDataSink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())
    private val recordingRunnable = object : Runnable {
        override fun run() {
            if (isRecording && audioRecord != null) {
                val bufferSize = AudioRecord.getMinBufferSize(
                    16000, // Sample rate
                    AudioFormat.CHANNEL_IN_MONO,
                    AudioFormat.ENCODING_PCM_16BIT
                )
                
                val buffer = ByteArray(bufferSize)
                val readSize = audioRecord!!.read(buffer, 0, bufferSize)
                
                if (readSize > 0 && audioDataSink != null) {
                    // Convert to List<Int> for Flutter
                    val intList = buffer.take(readSize).map { it.toInt() }
                    audioDataSink!!.success(intList)
                }
                
                // Continue recording
                handler.postDelayed(this, 50) // 50ms intervals
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Method channel for controlling microphone
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startRecording" -> {
                    startMicrophoneRecording(result)
                }
                "stopRecording" -> {
                    stopMicrophoneRecording(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Event channel for streaming audio data
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    audioDataSink = events
                }
                
                override fun onCancel(arguments: Any?) {
                    audioDataSink = null
                }
            }
        )
    }
    
    private fun startMicrophoneRecording(result: MethodChannel.Result) {
        try {
            if (isRecording) {
                result.success("Already recording")
                return
            }
            
            val bufferSize = AudioRecord.getMinBufferSize(
                16000, // Sample rate
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT
            )
            
            audioRecord = AudioRecord(
                MediaRecorder.AudioSource.MIC,
                16000, // Sample rate
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
                bufferSize
            )
            
            if (audioRecord!!.state != AudioRecord.STATE_INITIALIZED) {
                result.error("RECORDING_ERROR", "Failed to initialize AudioRecord", null)
                return
            }
            
            audioRecord!!.startRecording()
            isRecording = true
            
            // Start streaming audio data
            handler.post(recordingRunnable)
            
            result.success("Recording started")
        } catch (e: Exception) {
            result.error("RECORDING_ERROR", "Failed to start recording: ${e.message}", null)
        }
    }
    
    private fun stopMicrophoneRecording(result: MethodChannel.Result) {
        try {
            isRecording = false
            handler.removeCallbacks(recordingRunnable)
            
            audioRecord?.let { recorder ->
                if (recorder.recordingState == AudioRecord.RECORDSTATE_RECORDING) {
                    recorder.stop()
                }
                recorder.release()
            }
            audioRecord = null
            
            result.success("Recording stopped")
        } catch (e: Exception) {
            result.error("RECORDING_ERROR", "Failed to stop recording: ${e.message}", null)
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        // Create a simple result object for cleanup
        val cleanupResult = object : MethodChannel.Result {
            override fun success(result: Any?) {}
            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {}
            override fun notImplemented() {}
        }
        stopMicrophoneRecording(cleanupResult)
    }
}
