
class User
{
  late String id;
  late  String firstName;
  late  String lastName;
 late String email;

  late   String password;

  User( this.firstName, this.lastName, this.email, this.password);
 User.empty();
  Map<String, dynamic> toJson()
  {
    return
      {
      //  'id':id.isNotEmpty? id:'',
        'firstName':firstName,
        'lastName':lastName,
        'email':email,
        'password':password
      };
  }


  User.fromJson(Map<String, dynamic> json)
  {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    password = json['password'];

  }

  String getFilename()
  {
    return firstName[0]+lastName;
  }



}