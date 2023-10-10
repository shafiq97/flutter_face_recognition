import 'package:face_net_authentication/locator.dart';
import 'package:face_net_authentication/pages/models/user.model.dart';
import 'package:face_net_authentication/pages/profile.dart';
import 'package:face_net_authentication/pages/widgets/app_button.dart';
import 'package:face_net_authentication/pages/widgets/app_text_field.dart';
import 'package:face_net_authentication/services/camera.service.dart';
import 'package:flutter/material.dart';

class SignInSheet extends StatelessWidget {
  SignInSheet({Key? key, required this.user}) : super(key: key);
  final User user;

  final _passwordController = TextEditingController();
  final _cameraService = locator<CameraService>();

  Future _signIn(context, user) async {
    if (user.password == _passwordController.text) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => Profile(
                    user.user,
                    imagePath: _cameraService.imagePath!,
                  )));
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Wrong password!'),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Text(
              'Predicted Artist: ' + user.user + '.',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Container(
            child: Text(
              'Gender: ' + user.gender + '.',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Container(
            child: Text(
              'Birth Date: ' + user.dateOfBirth + '.',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Container(
            child: Text(
              'Education: ' + user.education + '.',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Container(
            child: Text(
              'Height: ' + user.height.toString() + '.',
              style: TextStyle(fontSize: 20),
            ),
          ),
          // Container(
          //   child: Column(
          //     children: [
          //       SizedBox(height: 10),
          //       AppTextField(
          //         controller: _passwordController,
          //         labelText: "Password",
          //         isPassword: true,
          //       ),
          //       SizedBox(height: 10),
          //       Divider(),
          //       SizedBox(height: 10),
          //       AppButton(
          //         text: 'OK',
          //         onPressed: () async {
          //           _signIn(context, user);
          //         },
          //         icon: Icon(
          //           Icons.login,
          //           color: Colors.white,
          //         ),
          //       )
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
