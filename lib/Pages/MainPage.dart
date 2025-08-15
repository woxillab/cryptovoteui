import 'package:flutter/material.dart';

import '../Models/BallotDTO.dart';
import '../Models/Candidate.dart';
import '../Models/Office.dart';
import '../Models/TokenRequestPayload.dart';
import '../Models/UserToken.dart';
import '../Models/VotePayload.dart';
import '../Models/VoterCardID.dart';
import '../Models/Wallet.dart';
import '../Service/CandidateService.dart';
import '../Service/ElectionService.dart';
import '../Service/FileService.dart';
import '../Widgets/ActionButton.dart';
import '../Widgets/InfoBox.dart';
import '../Widgets/SelectionList.dart';
import 'CardIdPage.dart';
import 'ConfirmationPage.dart';
import 'ResultPage.dart';

class MainPage extends StatefulWidget {
  final String walletName;

  const MainPage({super.key, required this.walletName});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String? selectedPresident;
  String? selectedSenator;
  String? selectedRepresentative;

  String? accountBalance;

  bool tokenAvailable = false;

  UserToken token = UserToken.empty();
  VoterCardId cardId = VoterCardId.empty();
  Wallet wallet = Wallet.empty();
  BallotDTO ballotDTO = BallotDTO.empty();

  final CandidateService candidateService = CandidateService();
  final FileService fileService = FileService.empty();
  final ElectionService electionService = ElectionService.empty();

  List<String> presidents = [];
  List<String> senators = [];
  List<String> representatives = [];
  List<Candidate> candidates = [];

  @override
  void initState()  {
    super.initState();
  //  WidgetsBinding.instance.addPostFrameCallback((_)
   // {
    updateFileObjectStatus();
       updateCandidateList();
    //refreshBalance();

   // });
  }

  Future<void> updateCandidateList() async {
    candidates = await candidateService.getAllCandidates();
    setState(() {
      presidents = candidates.where((c) => c.office == Office.President).map((c) => c.getFullName()).toList();
      senators = candidates.where((c) => c.office == Office.Senate).map((c) => c.getFullName()).toList();
      representatives = candidates.where((c) => c.office == Office.House).map((c) => c.getFullName()).toList();
    });
  }

  Future<void> updateFileObjectStatus() async {
    try {
      cardId = await VoterCardId.empty().loadFromFile(widget.walletName);
      token = await UserToken.empty().loadFromFile(widget.walletName);
      wallet = await Wallet.empty().loadFromFile(widget.walletName);
      tokenAvailable = token.userId.isNotEmpty;
    } catch (e) {
      debugPrint('Error loading file status: $e');
    }
    setState(() {});
  }

  Future<void> refreshBalance() async {
    wallet = await Wallet.empty().loadFromFile(widget.walletName);


     double  bal = await electionService.getAccountBalance(wallet);

    setState(() => accountBalance = bal.toString());
  }


  Future<void> requestToken() async {
    wallet = await Wallet.empty().loadFromFile(widget.walletName);
    print("submitted wallet:");
    print(wallet);
    final payload = TokenRequestPayload(wallet, cardId);
    token = await electionService.createNewId(payload);
    await token.saveToFile(widget.walletName);
    setState(() => tokenAvailable = true);
  }

  Future<void> submitVote() async {
    ballotDTO = BallotDTO.empty();
    ballotDTO.presidentID = await getCandidateId(Office.President);
    ballotDTO.senatorID = await getCandidateId(Office.Senate);
    ballotDTO.representativeID = await getCandidateId(Office.House);

    final payload = VotePayload(ballotDTO, token, wallet);
    final msg = await electionService.submitVote(payload);

    final snackBarMessage = (msg == '0x1')
        ? "Vote submitted successfully."
        : "Vote submission failed: Token can only be used once and only on election day.";

    if (msg == '0x1') {
      token.token = 0 as BigInt;
      await token.saveToFile(widget.walletName);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackBarMessage),
          backgroundColor: msg == '0x1' ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<String> getCandidateId(Office office) async {
    final fullName = switch (office.name) {
      'President' => selectedPresident,
      'Senate' => selectedSenator,
      'House' => selectedRepresentative,
      _ => null,
    };
    if (fullName == null) return '';
    final match = candidates.firstWhere(
          (c) => c.office == office && c.getFullName() == fullName,
      orElse: () => Candidate.empty(),
    );
    return match.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween, // You can keep or remove this, Flexible respects content size more
                children: [
                  Flexible(child: InfoBox(title: "Wallet", value: widget.walletName)),
                  const SizedBox(width: 8), // Added spacing between InfoBoxes
                  Flexible(child: InfoBox(title: "Token", value: tokenAvailable ? "Available" : "Not Available")),
                  const SizedBox(width: 8), // Added spacing between InfoBoxes
                  Flexible(child: InfoBox(title: "Balance", value: "$accountBalance ETH")), // Fixed value for design only
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ActionButton(
                    label: "Request Token",
                    onPressed: tokenAvailable
                        ? null
                        : () async {
                      if (!cardId.isValid()) {
                        await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CardIdPage(cardIdName: widget.walletName),
                        ));
                        await updateFileObjectStatus();
                      }
                      if (cardId.isValid()) {
                        await requestToken();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter a valid Voter Card ID.")),
                        );
                      }
                    },
                  ),
                  ActionButton(
                    label: "Refresh",
                    onPressed: ()
                    {
                      refreshBalance();
                     // updateFileObjectStatus();
                     // updateCandidateList();

                    }
                  ),
                  ActionButton(
                    label: "Result",
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ResultPage(wallet: wallet)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SelectionList(
                title: "President",
                items: presidents,
                selected: selectedPresident,
                onSelected: (val) => setState(() => selectedPresident = val),
              ),
              SelectionList(
                title: "Senator",
                items: senators,
                selected: selectedSenator,
                onSelected: (val) => setState(() => selectedSenator = val),
              ),
              SelectionList(
                title: "Representative",
                items: representatives,
                selected: selectedRepresentative,
                onSelected: (val) => setState(() => selectedRepresentative = val),
              ),
              const SizedBox(height: 10),
              const Text(
                "Note: You are only seeing candidates you're authorized to vote for.",
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: 180,
                  height: 56,
                  child: ActionButton(
                    label: "Submit Vote",
                    onPressed: (selectedPresident != null &&
                        selectedSenator != null &&
                        selectedRepresentative != null)
                        ? () async {
                      final confirmed = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(builder: (_) => const ConfirmationPage()),
                      );
                      if (confirmed == true) await submitVote();
                    }
                        : null,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}