import 'package:flutter/material.dart';
import '../Models/CandidateResult.dart';
import '../Models/Wallet.dart';
import '../Service/ElectionService.dart';

class ResultPage extends StatefulWidget {
  final Wallet wallet;

  const ResultPage({super.key, required this.wallet});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final ElectionService electionService = ElectionService.empty();

  List<CandidateResult> results = [];
  List<CandidateResult> filteredResults = [];

  String selectedOffice = 'All';
  String selectedCirconscription = 'All';
  bool sortDescending = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      results = await electionService.getResult(widget.wallet);
      setState(() {
        isLoading = false;
        _applyFilters();
      });
    } catch (e) {
      print('Error loading results: $e');
      debugPrintStack();
      setState(() {
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    filteredResults = results
        .where((r) =>
    (selectedOffice == 'All' || r.office.name == selectedOffice) &&
        (selectedCirconscription == 'All' ||
            r.circonscription.name == selectedCirconscription))
        .toList();
    _sortByVoteCount();
  }

  void _sortByVoteCount() {
    filteredResults.sort((a, b) => sortDescending
        ? b.voteCount.compareTo(a.voteCount)
        : a.voteCount.compareTo(b.voteCount));
  }

  List<String> getOffices() {
    final officeNames =
    results.map((r) => r.office.name).toSet().toList()..sort();
    return ['All', ...officeNames.where((e) => e != 'All')];
  }

  List<String> getCirconscriptions() {
    final circonscriptionNames =
    results.map((r) => r.circonscription.name).toSet().toList()..sort();
    return ['All', ...circonscriptionNames.where((e) => e != 'All')];
  }

  Map<String, CandidateResult> _getWinnersByOffice() {
    final winners = <String, CandidateResult>{};
    for (var result in results) {
      final office = result.office.name;
      if (!winners.containsKey(office) ||
          winners[office]!.voteCount < result.voteCount) {
        winners[office] = result;
      }
    }
    return winners;
  }

  @override
  Widget build(BuildContext context) {
    final winners = _getWinnersByOffice();

    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      appBar: AppBar(
        title: const Text("Election Results"),
        backgroundColor: Colors.blue.shade900,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.white30),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Winner panels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _winnerPanel("President", winners["President"]),
                  _winnerPanel("Senator", winners["Senate"]),
                  _winnerPanel("Representative", winners["House"]),
                ],
              ),
              const SizedBox(height: 20),

              // Filters
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Filter by Office",
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        DropdownButton<String>(
                          value: getOffices().contains(selectedOffice)
                              ? selectedOffice
                              : 'All',
                          items: getOffices()
                              .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e,
                                style: const TextStyle(
                                    color: Colors.white)),
                          ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedOffice = val!;
                              _applyFilters();
                            });
                          },
                          dropdownColor: Colors.blue.shade600,
                          isExpanded: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Filter by Circonscription",
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        DropdownButton<String>(
                          value: getCirconscriptions()
                              .contains(selectedCirconscription)
                              ? selectedCirconscription
                              : 'All',
                          items: getCirconscriptions()
                              .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e,
                                style: const TextStyle(
                                    color: Colors.white)),
                          ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedCirconscription = val!;
                              _applyFilters();
                            });
                          },
                          dropdownColor: Colors.blue.shade600,
                          isExpanded: true,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      sortDescending
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: Colors.white,
                    ),
                    tooltip: "Sort by vote count",
                    onPressed: () {
                      setState(() {
                        sortDescending = !sortDescending;
                        _sortByVoteCount();
                      });
                    },
                  )
                ],
              ),

              const SizedBox(height: 24),

              // Results table
              Expanded(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double containerWidth = constraints.maxWidth * 0.9;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          width: containerWidth,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                                Colors.white.withOpacity(0.2)),
                            columnSpacing: 24,
                            columns: const [
                              DataColumn(
                                  label: Text("Candidate",
                                      style: TextStyle(
                                          color: Colors.white))),
                              DataColumn(
                                  label: Text("Office",
                                      style: TextStyle(
                                          color: Colors.white))),
                              DataColumn(
                                  label: Text("Circonscription",
                                      style: TextStyle(
                                          color: Colors.white))),
                              DataColumn(
                                label: Text("Votes",
                                    style:
                                    TextStyle(color: Colors.white)),
                                numeric: true,
                              ),
                            ],
                            rows: filteredResults
                                .map((r) => DataRow(cells: [
                              DataCell(Text(r.name,
                                  style: const TextStyle(
                                      color: Colors.white))),
                              DataCell(Text(r.office.name,
                                  style: const TextStyle(
                                      color: Colors.white))),
                              DataCell(Text(
                                  r.circonscription.name,
                                  style: const TextStyle(
                                      color: Colors.white))),
                              DataCell(Text(
                                  r.voteCount.toString(),
                                  style: const TextStyle(
                                      color: Colors.white))),
                            ]))
                                .toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _winnerPanel(String office, CandidateResult? winner) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white30),
        ),
        child: Column(
          children: [
            Text(
              office,
              style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (winner != null) ...[
              Text(
                winner.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                "${winner.voteCount} votes",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ] else
              const Text(
                "No results",
                style: TextStyle(color: Colors.white70),
              ),
          ],
        ),
      ),
    );
  }
}
