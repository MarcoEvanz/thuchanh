import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditUser extends StatefulWidget {
  final User user;

  const EditUser({Key? key, required this.user}) : super(key: key);

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _genderController;
  late TextEditingController _birthDayController;
  late TextEditingController _schoolYearController;
  late TextEditingController _schoolKeyController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _phoneNumberController = TextEditingController(text: widget.user.phoneNumber);
    _genderController = TextEditingController(text: widget.user.gender);
    _birthDayController = TextEditingController(text: widget.user.birthDay);
    _schoolYearController = TextEditingController(text: widget.user.schoolYear);
    _schoolKeyController = TextEditingController(text: widget.user.schoolKey);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _genderController.dispose();
    _birthDayController.dispose();
    _schoolYearController.dispose();
    _schoolKeyController.dispose();
    super.dispose();
  }

  _saveUser() async {
    User updatedUser = User(
      idNumber: widget.user.idNumber,
      accountId: widget.user.accountId,
      fullName: _fullNameController.text,
      phoneNumber: _phoneNumberController.text,
      gender: _genderController.text,
      birthDay: _birthDayController.text,
      schoolYear: _schoolYearController.text,
      schoolKey: _schoolKeyController.text,
      imageURL: widget.user.imageURL,
      status: widget.user.status,
      dateCreated: widget.user.dateCreated,
    );

    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('user', jsonEncode(updatedUser.toJson()));

    Navigator.pop(context, updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh Sửa Thông Tin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveUser,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField(_fullNameController, 'Họ Tên'),
            _buildTextField(_phoneNumberController, 'Số ĐT'),
            _buildTextField(_genderController, 'Giới Tính'),
            _buildTextField(_birthDayController, 'Ngày Sinh'),
            _buildTextField(_schoolYearController, 'Năm Học'),
            _buildTextField(_schoolKeyController, 'Mã Trường'),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
