package io.dandelin

import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import us.zoom.sdk.*

class MainActivity: FlutterActivity(), ZoomSDKInitializeListener, MeetingServiceListener {

  private val CHANNEL = "dandelin"
  private val WEB_DOMAIN = "zoom.us"
  private val SDK_KEY = "cY6ECxzYLMmDdqZhyay4yUGa9mTSglVy0x9o"
  private val SDK_SECRET = "eQ1yhp8N1YVsTvBobL7C9GKAzt4YsrE4IlXp"
  private val DISPLAY_NAME = "Usuário do Zoom"
  private val PASSWORD = "123456"
  private val ZOOM_TOKEN = "eyJ6bV9za20iOiJ6bV9vMm0iLCJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJjbGllbnQiLCJ1aWQiOiJaZTZxMjJ6VlJ6NlJ2UUtGajYwNGJBIiwiaXNzIjoid2ViIiwic3R5Ijo5OSwid2NkIjoidXMwMiIsImNsdCI6MCwic3RrIjoiWF9FQjR4S0V1ZGtUdW1oSXhQWDBKOWIyTnhlcHo5bEVFc3BlN29ycENxTS5CZ1VzY1U1RWRrNDFXblpaZDB0SlkzVnFjSEpXZWpaVlZtWmljM05IYVRJMFYxWkljMVJpUmtnNVdrbHlaejBBQUF3elEwSkJkVzlwV1ZNemN6MEFCSFZ6TURJIiwiZXhwIjoxNTk4OTA0NDIyLCJpYXQiOjE1OTExMjg0MjIsImFpZCI6IjJzNmNmdU1zUVdPVEdOODNvbHpHUnciLCJjaWQiOiIifQ.YhamDfMNEMa1UtK10YJlk7IVz47N1tr4zqTuoro52iw"

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    MethodChannel(flutterView, CHANNEL).setMethodCallHandler {
      call, _ -> channel(call)
    }
  }

  override fun onResume() {
    super.onResume()
    init()
  }

  private fun init() {
    val zoomSDK = ZoomSDK.getInstance()
    if (!zoomSDK.isInitialized) {
      val initParams = ZoomSDKInitParams()
      initParams.enableLog = true
      initParams.logSize = 50
      initParams.appKey = SDK_KEY
      initParams.appSecret = SDK_SECRET
      initParams.domain = WEB_DOMAIN
      zoomSDK.initialize(this, this, initParams)
    }
    registerMeetingServiceListener()
  }

  private fun registerMeetingServiceListener() {
    val zoomSDK = ZoomSDK.getInstance()
    if (zoomSDK.isInitialized) {
      val meetingService = zoomSDK.meetingService
      meetingService?.apply {
        removeListener(this@MainActivity)
        addListener(this@MainActivity)
      }
    }
  }

  override fun onDestroy() {
    val zoomSDK = ZoomSDK.getInstance()
    if (zoomSDK.isInitialized) {
      val meetingService = zoomSDK.meetingService
      meetingService?.apply {
        removeListener(this@MainActivity)
      }
    }
    super.onDestroy()
  }

  private fun channel(call: MethodCall) {
    if (call.method == "openZoomActivity") {

      val request = call.arguments as Map<*, *>
      val userName = request["userName"] as String?
      val userId = request["userId"] as String?
      val meetingId = request["meetingId"] as Long?
      val doctorName = request["doctorName"] as String?
      val doctorExpertise = request["doctorExpertise"] as String?
      val doctorAvatar = request["doctorAvatar"] as String?

      val zoomSDK = ZoomSDK.getInstance()
      if (!zoomSDK.isInitialized) {
        return
      }

      val meetingService = zoomSDK.meetingService
      meetingService?.let {
        if (it.meetingStatus == MeetingStatus.MEETING_STATUS_IDLE) {
          startMeeting(userName, userId, meetingId, doctorName, doctorExpertise, doctorAvatar)
        } else {
          it.returnToMeeting(this@MainActivity)
        }
      }
    }
  }

  private fun startMeeting(userName: String?, userId: String?, meetingId: Long?, doctorName: String?,
                           doctorExpertise: String?, doctorAvatar: String?) {

    val zoomSDK = ZoomSDK.getInstance()
    if (!zoomSDK.isInitialized || userId == null || meetingId == null) {
      return
    }

    val meetingService = zoomSDK.meetingService
    val opts = JoinMeetingOptions()
    opts.no_driving_mode = true
    opts.no_titlebar = true
    opts.no_bottom_toolbar = true
    opts.no_invite = true


//    val paramsWithoutLogin = StartMeetingParamsWithoutLogin()
//    paramsWithoutLogin.userId = userId
//    paramsWithoutLogin.userType = MeetingService.USER_TYPE_ZOOM
//    paramsWithoutLogin.displayName = userName ?: DISPLAY_NAME
//    //paramsWithoutLogin.zoomToken = ZOOM_TOKEN
//    paramsWithoutLogin.zoomAccessToken = ZOOM_TOKEN
//    paramsWithoutLogin.meetingNo = meetingId.toString()

    val params = JoinMeetingParams()
    params.displayName = userName ?: DISPLAY_NAME
    params.meetingNo = meetingId.toString()
    params.password = PASSWORD


    val application = application as DandelinApplication
    application.doctorName = doctorName
    application.doctorExpertise = doctorExpertise
    application.doctorAvatar = doctorAvatar

    meetingService.joinMeetingWithParams(this, params, opts)
  }

  override fun onZoomSDKInitializeResult(errorCode: Int, internalErrorCode: Int) {
    if (errorCode == ZoomError.ZOOM_ERROR_SUCCESS) {
      registerMeetingServiceListener()
    }
  }

  override fun onMeetingStatusChanged(meetingStatus: MeetingStatus?, errorCode: Int, internalErrorCode: Int) { }

  override fun onZoomAuthIdentityExpired() { }
}
