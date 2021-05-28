[<img src="https://raw.githubusercontent.com/FirebaseExtended/flutterfire/master/resources/flutter_favorite.png" width="200" />](https://flutter.dev/docs/development/packages-and-plugins/favorites)

# Firebase Messaging Plugin for Flutter

A Flutter plugin to use the [Firebase Cloud Messaging API](https://firebase.google.com/docs/cloud-messaging).

To learn more about Firebase Cloud Messaging, please visit the [Firebase website](https://firebase.google.com/products/cloud-messaging)

## Getting Started

To get started with Firebase Cloud Messaging for Flutter, please [see the documentation](https://firebase.flutter.dev/docs/messaging/overview).


## Why flutter_fcm?

- 🚀 Easy to use 
- ⚡ Supports local notification


## Usage

The easiest way to use this library is via the top-level functions.

```dart
import 'package:flutter_fcm/flutter_fcm.dart';

init()async{
  try{
    await FCM.initializeFCM(
      onData: (Map<String, dynamic> data) {
        print(data);
      },
      onTokenChanged: (String token) {
        print(token);
      },
      icon: 'stem_cells'
    );
  }catch(e){}
}
```
 

  
