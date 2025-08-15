import 'dart:convert';
import 'dart:io';

import 'package:cryptovoteui/Models/IFile.dart';
import 'package:intl/intl.dart';

import 'Circonscription.dart';

class VoterCardId implements IFile
{

  final  String path = 'lib/Resources/Files/ID/';

  String userId='sdgdsfgdfghfg';
  late  String firstName='';
  late  String lastName='';
  late  String  nis='';
  late  String  dob=formatDate(DateTime.now());
  late Circonscription? circonscription;
  late  String electionDay  =formatDate(DateTime.now());
  late  String address='';


  VoterCardId( this.firstName, this.lastName, this.nis, this.dob,
      this.circonscription, this.electionDay, this.address);

  VoterCardId.empty();

  Map<String, dynamic> toJson()
  {
    return
      {
        'userId':userId,
        'firstName':firstName,
        'lastName':lastName,
        'nis':nis,
        'dob':dob,
        'circonscription': circonscription?.name,
        'electionDay' : electionDay,
        'address': address
      };
  }

  VoterCardId.fromJson(Map<String, dynamic> json)
  {
    userId = json['userId'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    nis = json['nis'];
   // dob = json['dob'];
    circonscription = Circonscription.values.byName(json['circonscription']);
//electionDay = json['electionDay'];
    address = json['address'];
  }

  @override
  Future<VoterCardId> loadFromFile(String fileName)  async {
    // TODO: implement loadFromFile
    String finalPath = '$path$fileName.txt';
    print('full path: $finalPath');
    final file= File(finalPath);
    final jsonString = await file.readAsString();
    final jsonMap = jsonDecode(jsonString);
    print('returned jsonMap');
    print(jsonMap);
    return VoterCardId.fromJson(jsonMap);
  }

  @override
  Future<void> saveToFile(String fileName) async {
    String finalPath = '$path$fileName.txt';
    final file = File(finalPath);
    final jsonString = jsonEncode(this.toJson());
    await file.writeAsString(jsonString);
  }

  bool isValid() {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        nis.isNotEmpty &&
        dob.toString().isNotEmpty &&
        circonscription.toString().isNotEmpty &&
        electionDay.toString().isNotEmpty &&
        address.isNotEmpty;
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }





}