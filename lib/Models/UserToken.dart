import 'dart:convert';
import 'dart:io';

import 'package:cryptovoteui/Models/IFile.dart';

class UserToken implements IFile {
  final String path = 'lib/Resources/Files/Token/';
  late String userId;
  late BigInt token;

  UserToken(this.userId, this.token);
  UserToken.empty();

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'token': token.toString(), // Important: pas de notation scientifique
    };
  }

  UserToken.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    print('Converting token from json');
    token = BigInt.parse('${json['token']}');
    print('Done converting token from json');
  }

  @override
  Future<void> saveToFile(String fileName) async {
    String finalPath = '$path$fileName.txt';
    final file = File(finalPath);
    final jsonString = jsonEncode(toJson());
    await file.writeAsString(jsonString);
  }

  @override
  Future<UserToken> loadFromFile(String fileName) async {
    String finalPath = '$path$fileName.txt';
    final file = File(finalPath);
    final jsonString = await file.readAsString();
    final jsonMap = jsonDecode(jsonString);
    return UserToken.fromJson(jsonMap);
  }
}
