import 'dart:convert';

import 'package:cryptovoteui/Models/CandidateResult.dart';
import 'package:cryptovoteui/Models/TokenRequestPayload.dart';
import 'package:cryptovoteui/Models/UserToken.dart';
import 'package:cryptovoteui/Models/VotePayload.dart';
import 'package:cryptovoteui/Models/Wallet.dart';

import '../Api/ApiService.dart';

class ElectionService
{
  ApiService apiService = ApiService();

  ElectionService.empty();

 Future<UserToken> createNewId(TokenRequestPayload payload) async
 {
   String endpoint = 'token';
   final response = await apiService.post(endpoint, payload);
   return UserToken.fromJson(json.decode(response.body));
 }

 Future<String> submitVote(VotePayload load) async
 {
   String endpoint = 'vote';
   final response = await apiService.post(endpoint, load);
   return response.body;
 }



  Future<List<CandidateResult>> getResult(Wallet wallet) async {
    try {
      String endpoint = 'result';
      final response = await apiService.post(endpoint, wallet);

      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => CandidateResult.fromJson(json)).toList();
    } catch (e) {
      print('Error parsing results: $e');
      return [];
    }
  }

 Future<double> getAccountBalance(Wallet wallet) async
 {
   print('wallet sent: ' );
   print(wallet.toJson());
   String endpoint = 'balance';
   final response = await apiService.post(endpoint, wallet);
   return double.parse(response.body);
 }



}