import UIKit
import Flutter
import GoogleMaps
  
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    
    
    NSSetUncaughtExceptionHandler { exception in
        print(Thread.callStackSymbols)
    }
    
    signal(SIGABRT) { _ in
        print( Thread.callStackSymbols)
    }
    
    signal(SIGILL) { _ in
        print(Thread.callStackSymbols)
    }
    
    signal(SIGSEGV) { _ in
        print(Thread.callStackSymbols)
    }
    
    signal(SIGFPE) { _ in
        print(Thread.callStackSymbols)
    }
    
    signal(SIGBUS) { _ in
        print(Thread.callStackSymbols)
    }
    
    signal(SIGPIPE) { _ in
        print(Thread.callStackSymbols)
    }
   
    GMSServices.provideAPIKey("AIzaSyCP640t45sxVo8lzLwijIMPPWYMxcUfI-A")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
