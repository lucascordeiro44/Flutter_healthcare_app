import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter_dandelin/firebase.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:intl/intl.dart';
import 'package:sentry/sentry.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

final SentryClient _sentry = new SentryClient(
    dsn: 'https://5e6acfdf7d6e4f7fa78dd81f264c5da2@sentry.io/1803884');

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

Future<Null> _reportError(dynamic error, dynamic stackTrace) async {
  print('Caught error: $error');
  // the report.
  if (!isInDebugMode) {
    print(stackTrace);
    print('In dev mode. Not sending report to Sentry.io.');
    //return;
    //}

    //print('Reporting to Sentry.io...');

    final SentryResponse response = await _sentry.captureException(
      exception: error,
      stackTrace: stackTrace,
    );

    if (response.isSuccessful) {
      print('Success! Event ID: ${response.eventId}');
    } else {
      print('Failed to report to Sentry.io: ${response.error}');
    }
  }
}

main() {
  FlutterError.onError = (FlutterErrorDetails details) async {
    Zone.current.handleUncaughtError(details.exception, details.stack);
    if (isInDebugMode) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to
      // Sentry.

    }
  };

  // ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
  //   Zone.current
  //       .handleUncaughtError(errorDetails.exception, errorDetails.stack);
  //   return ;
  // };

  Intl.defaultLocale = 'pt_BR';
  initializeDateFormatting();
  //Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors from the framework to Crashlytics.
  //FlutterError.onError = Crashlytics.instance.recordFlutterError;

//  AppBarUtils.setSystemBarWhiteColor();

  runZoned<Future<Null>>(() async {
    runApp(new MyApp());
  }, onError: (error, stackTrace) async {
    await _reportError(error, stackTrace);
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      blocs: [
        Bloc((i) => AppBloc()),
      ],
      child: AppWidget(),
    );
  }
}

class AppWidget extends StatefulWidget {
  @override
  _AppWidgetState createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [
        FirebaseAnalyticsObserver(
          analytics: analytics,
        ),
      ],
      navigatorKey: navigatorKey,
      localizationsDelegates: [],
      debugShowCheckedModeBanner: false,
      title: 'Dandelin',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Mark',
        primaryColor: Color.fromRGBO(248, 154, 73, 1),
        textTheme: TextTheme(
          body1: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
        ),
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(
            color: Color.fromRGBO(255, 174, 0, 1),
          ),
          textTheme: TextTheme(
            title: TextStyle(
              color: AppColors.greyStrong,
              fontSize: 20,
              fontFamily: 'Mark',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => HomePage(),
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
