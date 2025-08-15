import 'package:cryptovoteui/Models/Circonscription.dart';
import 'package:cryptovoteui/Models/Office.dart';

class CandidateResult
{
  late final String name;
  late final Office office;
  late final Circonscription circonscription;
  late final BigInt voteCount;

  CandidateResult(
     this.name,
     this.office,
     this.circonscription,
     this.voteCount,
  );

  Map<String, dynamic> toJson()
  {
    return
      {
        'name':name,
        'office':office.name,
        'circonscription':circonscription.name,
        'voteCount':voteCount

      };
  }

  CandidateResult.fromJson(Map<String, dynamic> json)
  {
    name = json['name'];
    office = Office.values.byName(json['office']);
    circonscription = Circonscription.values.byName(json['circonscription' ]);
    voteCount = BigInt.parse(json['voteCount'].toString());


  }

}
