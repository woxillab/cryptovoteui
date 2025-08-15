import 'Circonscription.dart';
import 'Office.dart';

class Candidate
{

  late String id;
  late String firstName;
  late String lastName;
  late Office office;
  late  bool isValid;
  late  Circonscription circonscription;

  Candidate(this.id, this.firstName, this.lastName, this.office, this.isValid,
      this.circonscription);
  Candidate.empty();


  Map<String, dynamic> toJson()
  {
    return
      {
        'id':id,
        'firstName':firstName,
        'lastName':lastName,
        'office':office,
        'isValid': isValid,
        'circonscription':circonscription
      };
  }

  Candidate.fromJson(Map<String, dynamic> json)
  {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    office = Office.values.byName(json['office']);
    isValid = json['isValid '] ?? false;
    circonscription = Circonscription.values.byName(json['circonscription']);

  }

 String  getFullName() {return '$firstName $lastName';}


}