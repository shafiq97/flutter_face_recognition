import 'dart:convert';

class User {
  String user;
  String gender; // Add gender field
  String dateOfBirth; // Add date of birth field
  double height; // Add height field
  String education; // Add education field
  List modelData;

  User({
    required this.user,
    required this.gender,
    required this.dateOfBirth,
    required this.height,
    required this.education,
    required this.modelData,
  });

  static User fromMap(Map<String, dynamic> user) {
    return User(
      user: user['user'],
      gender: user['gender'], // Update to include gender
      dateOfBirth: user['date_of_birth'], // Update to include date of birth
      height: user['height'].toDouble(), // Update to include height
      education: user['education'], // Update to include education
      modelData: jsonDecode(user['model_data']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'gender': gender, // Include gender in the map
      'date_of_birth': dateOfBirth, // Include date of birth in ISO 8601 format
      'height': height, // Include height in the map
      'education': education, // Include education in the map
      'model_data': jsonEncode(modelData),
    };
  }
}
