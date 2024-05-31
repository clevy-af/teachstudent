import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:teachstudent/colors.dart';

class AuthenticationPage extends StatefulWidget {
  AuthenticationPage({Key? key}) : super(key: key);

  @override
  AuthenticationPageState createState() {
    return new AuthenticationPageState();
  }
}

class AuthenticationPageState extends State<AuthenticationPage> {
  AuthenticationPageState(): super() {}

  // Authentication
  FirebaseAuth auth = FirebaseAuth.instance;
  String errorMessage = "";
  bool isLogin=true;
  String email='';
  String password='';

  registerAccountUsingEmail() async {
    bool success=false;
    try {
      await auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      success=true;
    } on FirebaseAuthException catch (err) {
      if (err.code == "weak-password") {
          errorMessage = "Please enter a stronger password";
      } else if (err.code == "email-already-in-use") {
          errorMessage = "This email has already been registered to another account";
      }
      setState(() {});

    }
    if(success) {
      auth.currentUser?.sendEmailVerification();
    }

  }

  Future<void> loginUsingEmail() async {
    try {
      await auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
    } on FirebaseAuthException catch (err) {
      if (err.code == "user-not-found") {
          errorMessage = "There is no account connected to this email address";
      } else if (err.code == "invalid-credential") {
          errorMessage = "Incorrect email / password";
      }else if (err.code == "too-many-requests") {
          errorMessage = "Too many requests, try again in a few minutes!";
      }
    setState(() {});
    }
  }

  final formKey = GlobalKey<FormState>(debugLabel: 'authForm');

  String? emailAddressValidator(String? email) {
    if (RegExp(
        r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
        .hasMatch(email??"")) {
      return null;
    }
      return "Please enter a valid email";
  }

  String? passwordValidator(String? password) {
    if(password==null) return '';
    if (password.length < 5) {
      return "Password must be at least 5 characters";
    } else if (password.length > 25) {
      return "Password must be at most 25 characters";
    }
    return null;
  }
  bool get isFormValid => formKey.currentState?.validate()==true;

  Future<void> onTapButton() async {
    if (isFormValid) {
      formKey.currentState!.save();
    }
    if(isLogin)
      await loginUsingEmail();
    else {
      await registerAccountUsingEmail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap:FocusScope.of(context).unfocus,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  colors: [
                    primaryColor,
                    primaryColor.withAlpha(800),
                  ]
              )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Spacer(),

              Visibility(
                visible: MediaQuery.of(context).viewInsets.bottom == 0,
                child: Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Animate(
                            effects: [
                              FadeEffect(
                            duration: Duration(milliseconds: 1000),
                              )
                            ],
                            child: Text("Welcome to", style: TextStyle(color: Colors.white, fontSize: 18),),
                        ),
                        SizedBox(height: 10,),
                        Animate(
                            effects: [
                              FadeEffect(
                                duration: Duration(milliseconds: 1000),
                              )
                            ],
                            child: Text("TeachStudent", style: TextStyle(color: Colors.white, fontSize: 40),),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(60))
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: <Widget>[
                        Spacer(),
                        Animate(
                            effects: [
                              FadeEffect(
                                duration: Duration(milliseconds: 1000),
                              )
                            ], child: Card.outlined(
                          shadowColor: Colors.white12,
                          color: Colors.white,
                              child: Form(
                                key: formKey,
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                                      ),
                                      child: TextFormField(
                                        style: TextStyle(decoration: TextDecoration.none),
                                          decoration: const InputDecoration(
                                              labelText: "Email",
                                            enabledBorder: InputBorder.none,
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                          ),
                                          validator: this.emailAddressValidator,
                                          onSaved: (value) {
                                            email = value?.trim()??'';
                                          }
                                      )
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                                      ),
                                      child: TextFormField(
                                        obscureText: true,
                                        decoration: const InputDecoration(
                                            labelText: "Password",
                                          enabledBorder: InputBorder.none,
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                        ),
                                        validator: this.passwordValidator,
                                        onSaved: (value) {
                                          password = value?.trim()??'';
                                        },
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            )),
                        Spacer(),

                        Center(
                            child: Text(
                                errorMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red
                                )
                            )
                        ),
                        Spacer(),
                        Animate(
                            effects: [
                              FadeEffect(
                                duration: Duration(milliseconds: 1500),
                              )
                            ],child: Text.rich(
                              TextSpan(text:isLogin?"No account? Sign up.":"Have an account? Login.",recognizer: TapGestureRecognizer()..onTap=(){
                                setState(() {
                                  isLogin=!isLogin;
                                });
                              }),
                              style: TextStyle(color: Colors.grey,),

                            )
                        ),
                        Spacer(),
                        Animate(
                            effects: [
                              FadeEffect(
                                duration: Duration(milliseconds: 1600),
                              )
                            ], child: MaterialButton(
                          onPressed:onTapButton,
                          height: 50,
                          color: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),

                          ),
                          child: Center(
                            child: Text(isLogin?"Login":"Sign up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}