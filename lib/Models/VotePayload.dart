import 'package:cryptovoteui/Models/BallotDTO.dart';
import 'package:cryptovoteui/Models/UserToken.dart';
import 'package:cryptovoteui/Models/Wallet.dart';

class VotePayload
{
  late BallotDTO ballotDTO;
  late UserToken token;
  late Wallet wallet;

  VotePayload(this.ballotDTO, this.token, this.wallet);


  Map<String, dynamic> toJson()
  {
    return
      {
        'ballotDTO':ballotDTO.toJson(),
        'token':token.toJson(),
        'wallet':wallet.toJson(),
      };
  }


  VotePayload.fromJson(Map<String, dynamic> json)
  {
    wallet = Wallet.fromJson(json['wallet']);
    ballotDTO = BallotDTO.fromJson(json['ballotDTO']);
    token = UserToken.fromJson(json['token']);

  }


}