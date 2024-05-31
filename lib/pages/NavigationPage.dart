import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teachstudent/pages/LoadingPage.dart';
import 'bottomNavigationPages/AuthenticationPage.dart';
import 'bottomNavigationPages/CloudFirestorePage.dart';

class NavigationPage extends StatefulWidget {
  NavigationPage({Key? key}) : super(key: key);

  @override
  NavigationPageState createState() {
    return NavigationPageState();
  }
}

class NavigationPageState extends State<NavigationPage> {
  NavigationPageState() : super() {}
  // Authentication
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<User?>(
          stream:  auth.authStateChanges(),
          builder: (context, snapshot) {
            if(snapshot.connectionState==ConnectionState.waiting)
              return LoadingPage();
            if(snapshot.hasData&&snapshot.data!=null)
              return CloudFirestorePage();
            return AuthenticationPage();
        }
      );
  }
}