 import 'dart:convert';

import 'package:cryptovoteui/Api/ApiService.dart';
import 'package:cryptovoteui/Models/Wallet.dart';

import '../Models/User.dart';

class WalletService
 {

   ApiService apiService = ApiService();
   WalletService.empty();


   Future<Wallet> register(User user) async
   {
      String endpoint = 'register';
      final response = await apiService.post(endpoint, user);
      return Wallet.fromJson(json.decode(response.body));
   }

 }