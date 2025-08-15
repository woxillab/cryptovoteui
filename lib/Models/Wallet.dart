import 'package:cryptovoteui/Models/IFile.dart';
import 'dart:io';
import 'dart:convert';

class Wallet implements IFile {
  final String path = 'lib/Resources/Files/Wallet/';

  late String userId;
  late String privateKey;
  late String publicKey;
  late String address;

  Wallet(this.userId, this.privateKey, this.publicKey, this.address);

  Wallet.empty();



  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'privateKey': privateKey,
      'publicKey': publicKey,
      'address': address,
    };
  }

  static Wallet fromJson(Map<String, dynamic> json) {
    return Wallet(
      json['userId'],
      json['privateKey'],
      json['publicKey'],
      json['address'],
    );
  }

  @override
  Future<Wallet> loadFromFile(String fileName) async {
    String finalPath = '$path$fileName.txt';
    final file = File(finalPath);
    final jsonString = await file.readAsString();
    final jsonMap = jsonDecode(jsonString);
    return Wallet.fromJson(jsonMap); // fixed
  }

  @override
  Future<void> saveToFile(String fileName) async {
    String finalPath = '$path$fileName.txt';
    final file = File(finalPath);
    final jsonString = jsonEncode(toJson());
    await file.writeAsString(jsonString);
  }
}
