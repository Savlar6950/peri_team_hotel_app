// Generated file. Do not edit.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBno5Z8aE6ubfzCa491ZdBAP03PInfkqrU",
    appId: "1:792119255949:web:replace-this-if-you-create-web-app",
    messagingSenderId: "792119255949",
    projectId: "peri-team-hotel-app",
    databaseURL: "https://peri-team-hotel-app-default-rtdb.europe-west1.firebasedatabase.app",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyBno5Z8aE6ubfzCa491ZdBAP03PInfkqrU",
    appId: "1:792119255949:android:79599bbb4b1b24ee2593c4",
    messagingSenderId: "792119255949",
    projectId: "peri-team-hotel-app",
    databaseURL: "https://peri-team-hotel-app-default-rtdb.europe-west1.firebasedatabase.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyBno5Z8aE6ubfzCa491ZdBAP03PInfkqrU",
    appId: "1:792119255949:ios:replace-this-if-you-add-ios-app",
    messagingSenderId: "792119255949",
    projectId: "peri-team-hotel-app",
    databaseURL: "https://peri-team-hotel-app-default-rtdb.europe-west1.firebasedatabase.app",
  );

  static const FirebaseOptions macos = ios;
  static const FirebaseOptions windows = android;
}
