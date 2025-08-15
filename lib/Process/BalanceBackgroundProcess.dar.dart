import '../Models/Wallet.dart';
import '../Service/ElectionService.dart';

class BalanceBackgroundProcess {
  final ElectionService electionService;

  BalanceBackgroundProcess({ElectionService? electionService})
      : electionService = electionService ?? ElectionService.empty();

  /// Fetches the account balance for the provided wallet.
  /// Returns a double representing the balance.
  Future<double> fetchBalance(Wallet wallet) async {
    try {
      final balance = await electionService.getAccountBalance(wallet);
      return balance;
    } catch (e) {
      // You can handle logging or rethrow here if needed
      return 0.0;
    }
  }
}
