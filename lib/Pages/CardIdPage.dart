import 'package:cryptovoteui/Models/Circonscription.dart';
import 'package:cryptovoteui/Models/VoterCardID.dart';
import 'package:cryptovoteui/Service/FileService.dart';
import 'package:cryptovoteui/Utililities/DateMGM.dart';
import 'package:flutter/material.dart';



class CardIdPage extends StatefulWidget {
  final String cardIdName;
  const CardIdPage({super.key, required this.cardIdName});

  @override
  State<CardIdPage> createState() => _CardIdPageState();
}

class _CardIdPageState extends State<CardIdPage> {
  final _formKey = GlobalKey<FormState>();

  String userId = '';
  String firstName = '';
  String lastName = '';
  String nis = '';
  DateTime? dob;
  Circonscription? circonscription;
  DateTime? electionDay;
  String address = '';

  final TextEditingController dobController = TextEditingController();
  final TextEditingController electionDayController = TextEditingController();

  FileService fileService = FileService.empty();

  @override
  void dispose() {
    dobController.dispose();
    electionDayController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller, Function(DateTime) onSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = "${picked.toLocal()}".split(' ')[0];
      onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Identity Card Form", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField("User ID", (val) => userId = val),
                _buildTextField("First Name", (val) => firstName = val),
                _buildTextField("Last Name", (val) => lastName = val),
                _buildTextField("NIS", (val) => nis = val),
                _buildDatePicker("Date of Birth", dobController, (val) => dob = val),
                _buildDropdownField("Circonscription", Circonscription.values, circonscription, (val) {
                  setState(() => circonscription = val);
                }),
                _buildDatePicker("Election Day", electionDayController, (val) => electionDay = val),
                _buildTextField("Address", (val) => address = val),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton("Cancel", () {
                      Navigator.pop(context);
                    }, color: Colors.redAccent),
                    _buildActionButton("Submit", () {
                      if (_formKey.currentState!.validate() &&
                          dob != null &&
                          electionDay != null &&
                          circonscription != null) {
                        _formKey.currentState!.save();
                        // Handle data submission here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Form submitted successfully")),
                        );
                        saveCard();
                        Navigator.pop(context); // Optionally close page
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please complete all fields")),
                        );
                      }
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String) onSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label),
        validator: (value) => (value == null || value.isEmpty) ? "Required" : null,
        onSaved: (value) => onSaved(value!),
      ),
    );
  }

  Widget _buildDatePicker(String label, TextEditingController controller, Function(DateTime) onSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label),
        onTap: () => _selectDate(context, controller, onSelected),
        validator: (_) => controller.text.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildDropdownField<T>(
      String label,
      List<T> options,
      T? selectedValue,
      Function(T) onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<T>(
        value: selectedValue,
        decoration: _inputDecoration(label),
        dropdownColor: Colors.blue.shade700,
        style: const TextStyle(color: Colors.white),
        iconEnabledColor: Colors.white,
        items: options.map((T value) {
          return DropdownMenuItem<T>(
            value: value,
            child: Text(value.toString().split('.').last),
          );
        }).toList(),
        onChanged: (T? value) {
          if (value != null) onChanged(value);
        },
        validator: (value) => value == null ? "Required" : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
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
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed, {Color? color}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        backgroundColor: color ?? Colors.white,
        foregroundColor: color != null ? Colors.white : Colors.blue.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  void saveCard()
  {
    VoterCardId voterCardId = VoterCardId( firstName, lastName, nis, DateMGM.formatDate(dob!), circonscription ,  DateMGM.formatDate(electionDay!), address);
    if(voterCardId.isValid())
    {
      voterCardId.saveToFile(widget.cardIdName);
    }
    else
    {
      print('Voter Card is not valid');
    }
  }
}
