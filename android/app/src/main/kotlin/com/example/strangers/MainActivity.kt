package com.example.strangers
import live.hms.hmssdk_flutter.HmssdkFlutterPlugin
import android.app.Activity 
import android.content.Intent
import live.hms.hmssdk_flutter.Constants



import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

 override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    super.onActivityResult(requestCode, resultCode, data)

    if (requestCode == Constants.SCREEN_SHARE_INTENT_REQUEST_CODE && resultCode == Activity.RESULT_OK){
        HmssdkFlutterPlugin.hmssdkFlutterPlugin?.requestScreenShare(data)
    }
}

}
