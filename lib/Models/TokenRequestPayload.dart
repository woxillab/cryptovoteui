
import 'package:cryptovoteui/Models/VoterCardID.dart';

import 'Wallet.dart';

class TokenRequestPayload
{
  late Wallet wallet;
  late VoterCardId cardId;


  TokenRequestPayload(this.wallet, this.cardId);

  Map<String, dynamic> toJson()
  {
    return
      {
        'wallet':wallet.toJson(),
        'cardId':cardId.toJson()
      };
  }


  TokenRequestPayload.fromJson(Map<String, dynamic> json)
  {
    wallet = Wallet.fromJson(json['wallet']);
    cardId = VoterCardId.fromJson(json['cardId']);

  }


}