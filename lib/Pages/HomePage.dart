import 'package:cryptovoteui/Pages/WalletPage.dart';
import 'package:cryptovoteui/Service/FileService.dart';
import 'package:cryptovoteui/Utililities/FileType.dart';
import 'package:flutter/material.dart';

import '../Models/User.dart';
import '../Models/Wallet.dart';
import '../Service/WalletService.dart';
import 'MainPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  WalletService walletService = WalletService.empty();
  FileService fileService = FileService.empty();

  List<String> dropdownItems = ['None'];
  String selectedOption = 'None';

  @override
  void initState() {
    super.initState();
    updateDropDownItem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text(
                            "VOTECHAIN",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildTextField("First Name", firstNameController),
                        _buildTextField("Last Name", lastNameController),
                        _buildTextField("Email", emailController),
                        _buildTextField("Password", passwordController, obscure: true),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () async {
                            Wallet wallet = await registerUser();
                            if (wallet.userId.isNotEmpty) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => WalletPage(wallet: wallet)));
                              updateDropDownItem();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Create New Wallet",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Divider(color: Colors.white.withOpacity(0.3)),
                        const SizedBox(height: 20),
                        Text(
                          "Load wallet",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: dropdownItems.contains(selectedOption)
                                  ? selectedOption
                                  : 'None',
                              dropdownColor: Colors.blue.shade600,
                              iconEnabledColor: Colors.white,
                              style: const TextStyle(color: Colors.white),
                              items: dropdownItems.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedOption = newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () async {
                            if (selectedOption == 'None') return;
                            Wallet wallet = await loadWalletFromFile();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    MainPage(walletName: selectedOption)));
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Load Wallet",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white30),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<Wallet> registerUser() async {
    String? firstName =
    firstNameController.text.isNotEmpty ? firstNameController.text : null;
    String? lastName =
    lastNameController.text.isNotEmpty ? lastNameController.text : null;
    String? email = emailController.text.isNotEmpty ? emailController.text : null;
    String? password =
    passwordController.text.isNotEmpty ? passwordController.text : null;

    Wallet wallet = Wallet.empty();
    if (firstName == null || lastName == null || email == null || password == null) {
      print('Please fill all fields');
      return wallet;
    }

    User user = User(firstName, lastName, email, password);
    wallet = await walletService.register(user);
    await wallet.saveToFile('${firstName[0]}$lastName');
    return wallet;
  }

  void updateDropDownItem() async {
    final List<String> fileNames =
    await fileService.getListOfFile(FileType.WALLET);

    if (fileNames.isNotEmpty) {
      setState(() {
        dropdownItems = fileNames;
        selectedOption = fileNames.first;
      });
    } else {
      setState(() {
        dropdownItems = ['None'];
        selectedOption = 'None';
      });
    }
  }

  Future<Wallet> loadWalletFromFile() async {
    Wallet wallet = Wallet.empty();
    if (selectedOption != 'None') {
      wallet = await wallet.loadFromFile(selectedOption);
    }
    return wallet;
  }
}
