class BallotDTO
{
 late  String presidentID;
  late  String  representativeID;
 late   String senatorID;

 BallotDTO(this.presidentID, this.representativeID, this.senatorID);
 BallotDTO.empty();

 Map<String, dynamic> toJson()
 {
   return
     {
       'presidentID':presidentID,
       'representativeID':representativeID,
       'senatorID':senatorID
     };
 }

BallotDTO.fromJson(Map<String, dynamic> json)
 {
   presidentID = json['presidentID'];
   representativeID = json['representativeID'];
   senatorID = json['senatorID'];
 }


}