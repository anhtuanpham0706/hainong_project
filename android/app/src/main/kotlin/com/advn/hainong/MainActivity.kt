package com.advn.hainong

import android.Manifest.permission.POST_NOTIFICATIONS
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import com.zing.zalo.zalosdk.oauth.ZaloSDK

class MainActivity: FlutterActivity() {
    override fun onActivityResult(requestCode:Int, resultCode:Int, data: Intent?) {
       if (data != null) {
           super.onActivityResult(requestCode, resultCode, data)
           if(data.data != null) {
               ZaloSDK.Instance.onActivityResult(this, requestCode, resultCode, data)
           }
       } else {
           super.onActivityResult(requestCode, resultCode, Intent())
       }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (ContextCompat.checkSelfPermission(this, POST_NOTIFICATIONS) == PackageManager.PERMISSION_DENIED) {
            ActivityCompat.requestPermissions(this, Array(1){POST_NOTIFICATIONS}, 1)
        }
    }
}
