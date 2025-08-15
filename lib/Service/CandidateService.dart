import 'dart:convert';

import 'package:cryptovoteui/Models/Candidate.dart';

import '../Api/ApiService.dart';

class CandidateService
{
  ApiService apiService = ApiService();


  Future<Candidate> register(Candidate candidate) async
  {
    String endpoint = 'candidate';
    final response = await apiService.post(endpoint, candidate);
    return Candidate.fromJson(json.decode(response.body));
  }


  Future<List<Candidate>> getAllCandidates() async {
    String endpoint = 'candidate';
    final response = await apiService.get(endpoint);

    final List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((item) => Candidate.fromJson(item)).toList();
  }
}