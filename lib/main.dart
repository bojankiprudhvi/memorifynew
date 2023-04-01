import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/providers/user_provider.dart';
import 'package:instagram_flutter/responsive/mobile_screen_layout.dart';
import 'package:instagram_flutter/responsive/responsive_layout_screen.dart';
import 'package:instagram_flutter/responsive/web_screen_layout.dart';
import 'package:instagram_flutter/screens/login_screen.dart';
import 'package:instagram_flutter/screens/signup_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'dart:developer' as devtools show log;

import 'package:provider/provider.dart';

void main() async {
  if (kIsWeb) {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyB_fhLxujGM303qUf4uTEYEL7zIeUpPm6U",
        authDomain: "instagram-clone-ce57e.firebaseapp.com",
        projectId: "instagram-clone-ce57e",
        storageBucket: "instagram-clone-ce57e.appspot.com",
        messagingSenderId: "449525375375",
        appId: "1:449525375375:web:a9e55274432742ec476bfa",
      ),
    ).whenComplete(
      () => devtools.log("Successfully Initialized For Web"),
    );
  } else {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp().whenComplete(
      () => devtools.log("Successfully Initialized For Mobile"),
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instagram Clone',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor,
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
                if (snapshot.hasData) {
                  return ResponsiveLayout(
                    mobileScreenLayout: MobileScreenLayout(),
                    webScreenLayout: WebScreenLayout(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return const LoginScreen();
                }
              case ConnectionState.waiting:
                return const Center(
                  child: CircularProgressIndicator(
                    color: blueColor,
                  ),
                );

              default:
                return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}
