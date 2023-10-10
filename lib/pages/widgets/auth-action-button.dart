import 'package:face_net_authentication/locator.dart';
import 'package:face_net_authentication/pages/db/databse_helper.dart';
import 'package:face_net_authentication/pages/models/user.model.dart';
import 'package:face_net_authentication/pages/profile.dart';
import 'package:face_net_authentication/pages/widgets/app_button.dart';
import 'package:face_net_authentication/services/camera.service.dart';
import 'package:face_net_authentication/services/ml_service.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart';

import '../home.dart';
import 'app_text_field.dart';

class AuthActionButton extends StatefulWidget {
  AuthActionButton({
    Key? key,
    required this.onPressed,
    required this.isLogin,
    required this.reload,
  });
  final Function onPressed;
  final bool isLogin;
  final Function reload;
  @override
  _AuthActionButtonState createState() => _AuthActionButtonState();
}

class _AuthActionButtonState extends State<AuthActionButton> {
  final MLService _mlService = locator<MLService>();
  final CameraService _cameraService = locator<CameraService>();

  final TextEditingController _userTextEditingController =
      TextEditingController(text: '');
  final TextEditingController _genderTextEditingController =
      TextEditingController(text: '');
  final TextEditingController _dateOfBirthTextEditingController =
      TextEditingController(text: '');
  final TextEditingController _heightTextEditingController =
      TextEditingController(text: '');
  final TextEditingController _educationTextEditingController =
      TextEditingController(text: '');

  User? predictedUser;
  DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future _signUp(context) async {
    List predictedData = _mlService.predictedData;
    String user = _userTextEditingController.text;
    String gender = _genderTextEditingController.text;
    String dateOfBirth = _dateOfBirthTextEditingController.text;
    double height = double.parse(_heightTextEditingController.text);
    String education = _educationTextEditingController.text;

    User userToSave = User(
      user: user,
      gender: gender,
      dateOfBirth: dateOfBirth,
      height: height,
      education: education,
      modelData: predictedData,
    );

    await _databaseHelper.insert(userToSave);
    this._mlService.setPredictedData([]);
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => MyHomePage()));
  }

  Future _signIn(context) async {
    String user = _userTextEditingController.text;
    User? userFromDB = await _databaseHelper.getUserByUsername(user);

    if (userFromDB != null) {
      if (userFromDB.gender == _genderTextEditingController.text &&
          userFromDB.dateOfBirth ==
              DateTime.parse(_dateOfBirthTextEditingController.text) &&
          userFromDB.height ==
              double.parse(_heightTextEditingController.text) &&
          userFromDB.education == _educationTextEditingController.text) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => Profile(
              userFromDB.user,
              imagePath: _cameraService.imagePath!,
            ),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content:
                  Text('Authentication failed! Please check your credentials.'),
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('User not found!'),
          );
        },
      );
    }
  }

  Future<User?> _predictUser() async {
    User? userAndPass = await _mlService.predict();
    return userAndPass;
  }

  Future onTap() async {
    try {
      bool faceDetected = await widget.onPressed();
      if (faceDetected) {
        if (widget.isLogin) {
          var user = await _predictUser();
          if (user != null) {
            this.predictedUser = user;
          }
        }
        PersistentBottomSheetController bottomSheetController =
            Scaffold.of(context)
                .showBottomSheet((context) => signSheet(context));
        bottomSheetController.closed.whenComplete(() => widget.reload());
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue[200],
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.8,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CAPTURE',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(Icons.camera_alt, color: Colors.white)
          ],
        ),
      ),
    );
  }

  signSheet(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.isLogin && predictedUser != null
              ? Container(
                  child: Text(
                    'Welcome back, ' + predictedUser!.user + '.',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : widget.isLogin
                  ? Container(
                      child: Text(
                      'User not found 😞',
                      style: TextStyle(fontSize: 20),
                    ))
                  : Container(),
          Container(
            child: Column(
              children: [
                !widget.isLogin
                    ? AppTextField(
                        controller: _userTextEditingController,
                        labelText: "Artist Name",
                      )
                    : Container(),
                SizedBox(height: 10),
                AppTextField(
                  controller: _genderTextEditingController,
                  labelText: "Gender",
                ),
                SizedBox(height: 10),
                AppTextField(
                  controller: _dateOfBirthTextEditingController,
                  labelText: "Date of Birth",
                ),
                SizedBox(height: 10),
                AppTextField(
                  controller: _heightTextEditingController,
                  labelText: "Height",
                ),
                SizedBox(height: 10),
                AppTextField(
                  controller: _educationTextEditingController,
                  labelText: "Education",
                ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                widget.isLogin && predictedUser != null
                    ? AppButton(
                        text: 'PERDICT ARTIST',
                        onPressed: () async {
                          _signIn(context);
                        },
                        icon: Icon(
                          Icons.login,
                          color: Colors.white,
                        ),
                      )
                    : !widget.isLogin
                        ? AppButton(
                            text: 'REGISTER ARTIST',
                            onPressed: () async {
                              await _signUp(context);
                            },
                            icon: Icon(
                              Icons.person_add,
                              color: Colors.white,
                            ),
                          )
                        : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
