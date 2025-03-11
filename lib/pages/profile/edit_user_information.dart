import 'dart:convert';
import 'package:massage_2025_mobile/home_v2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as dt_picker;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:massage_2025_mobile/pages/blank_page/dialog_fail.dart';
import 'package:massage_2025_mobile/shared/api_provider.dart';
import 'package:massage_2025_mobile/widget/text_form_field.dart';

class EditUserInformationPage extends StatefulWidget {
  @override
  _EditUserInformationPageState createState() =>
      _EditUserInformationPageState();
}

class _EditUserInformationPageState extends State<EditUserInformationPage> {
  final storage = new FlutterSecureStorage();

  late String _imageUrl = '';
  late String _code;

  final _formKey = GlobalKey<FormState>();

  List<String> _itemPrefixName = ['นาย', 'นาง', 'นางสาว']; // Option 2
  late String _selectedPrefixName;

  List<dynamic> _itemSex = [
    {'title': 'ชาย', 'code': 'ชาย'},
    {'title': 'หญิง', 'code': 'หญิง'},
    {'title': 'ไม่ระบุเพศ', 'code': ''}
  ];
  late String _selectedSex;

  List<dynamic> _itemProvince = [];
  late String _selectedProvince;

  List<dynamic> _itemDistrict = [];
  late String _selectedDistrict;

  List<dynamic> _itemSubDistrict = [];
  late String _selectedSubDistrict;

  List<dynamic> _itemPostalCode = [];
  late String _selectedPostalCode;

  final txtEmail = TextEditingController();
  final txtPassword = TextEditingController();
  final txtConPassword = TextEditingController();
  final txtPrefixName = TextEditingController();
  final txtFirstName = TextEditingController();
  final txtLastName = TextEditingController();
  final txtPhone = TextEditingController();
  final txtUsername = TextEditingController();
  final txtIdCard = TextEditingController();
  final txtLineID = TextEditingController();
  final txtOfficerCode = TextEditingController();
  final txtAddress = TextEditingController();
  final txtMoo = TextEditingController();
  final txtSoi = TextEditingController();
  final txtRoad = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TextEditingController txtDate = TextEditingController();

  late Future<dynamic> futureModel;

  ScrollController scrollController = new ScrollController();

  late XFile _image;

  int _selectedDay = 0;
  int _selectedMonth = 0;
  int _selectedYear = 0;
  int year = 0;
  int month = 0;
  int day = 0;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtEmail.dispose();
    txtPassword.dispose();
    txtConPassword.dispose();
    txtFirstName.dispose();
    txtLastName.dispose();
    txtPhone.dispose();
    txtDate.dispose();
    super.dispose();
  }

  @override
  void initState() {
    futureModel = getUser();

    scrollController = ScrollController();
    var now = new DateTime.now();
    setState(() {
      year = now.year;
      month = now.month;
      day = now.day;
      _selectedYear = now.year;
      _selectedMonth = now.month;
      _selectedDay = now.day;
    });
    super.initState();
  }

  Future<dynamic> getProvince() async {
    final result = await postObjectData("route/province/read", {});
    if (result['status'] == 'S') {
      setState(() {
        _itemProvince = result['objectData'];
      });
    }
  }

  Future<dynamic> getDistrict() async {
    final result = await postObjectData("route/district/read", {
      'province': _selectedProvince,
    });
    if (result['status'] == 'S') {
      setState(() {
        _itemDistrict = result['objectData'];
      });
    }
  }

  Future<dynamic> getSubDistrict() async {
    final result = await postObjectData("route/tambon/read", {
      'province': _selectedProvince,
      'district': _selectedDistrict,
    });
    if (result['status'] == 'S') {
      setState(() {
        _itemSubDistrict = result['objectData'];
      });
    }
  }

  Future<dynamic> getPostalCode() async {
    final result = await postObjectData("route/postcode/read", {
      'tambon': _selectedSubDistrict,
    });
    if (result['status'] == 'S') {
      setState(() {
        _itemPostalCode = result['objectData'];
      });
    }
  }

  bool isValidDate(String input) {
    try {
      final date = DateTime.parse(input);
      final originalFormatString = toOriginalFormatString(date);
      return input == originalFormatString;
    } catch (e) {
      return false;
    }
  }

  String toOriginalFormatString(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    return "$y$m$d";
  }

  Future<dynamic> getUser() async {
    var profileCode = await storage.read(key: 'profileCode3');

    if (profileCode != '') {
      final result =
          await postObjectData("m/Register/read", {'code': profileCode});

      if (result['status'] == 'S') {
        await storage.write(
          key: 'dataUserLoginOPEC',
          value: jsonEncode(result['objectData'][0]),
        );

        if (result['objectData'][0]['birthDay'] != '') {
          if (isValidDate(result['objectData'][0]['birthDay'])) {
            var date = result['objectData'][0]['birthDay'];
            var year = date.substring(0, 4);
            var month = date.substring(4, 6);
            var day = date.substring(6, 8);
            DateTime todayDate = DateTime.parse(year + '-' + month + '-' + day);
            setState(() {
              _selectedYear = todayDate.year;
              _selectedMonth = todayDate.month;
              _selectedDay = todayDate.day;
              txtDate.text = DateFormat("dd-MM-yyyy").format(todayDate);
            });
          }
        }

        setState(() {
          _imageUrl = result['objectData'][0]['imageUrl'] ?? '';
          txtFirstName.text = result['objectData'][0]['firstName'] ?? '';
          txtLastName.text = result['objectData'][0]['lastName'] ?? '';
          txtEmail.text = result['objectData'][0]['email'] ?? '';
          txtPhone.text = result['objectData'][0]['phone'] ?? '';
          _selectedPrefixName = result['objectData'][0]['prefixName'];
          _code = result['objectData'][0]['code'] ?? '';
          txtPhone.text = result['objectData'][0]['phone'] ?? '';
          txtUsername.text = result['objectData'][0]['username'] ?? '';
          txtIdCard.text = result['objectData'][0]['idcard'] ?? '';
          txtLineID.text = result['objectData'][0]['lineID'] ?? '';
          txtOfficerCode.text = result['objectData'][0]['officerCode'] ?? '';
          txtAddress.text = result['objectData'][0]['address'] ?? '';
          txtMoo.text = result['objectData'][0]['moo'] ?? '';
          txtSoi.text = result['objectData'][0]['soi'] ?? '';
          txtRoad.text = result['objectData'][0]['road'] ?? '';
          txtPrefixName.text = result['objectData'][0]['prefixName'] ?? '';

          _selectedProvince = result['objectData'][0]['provinceCode'] ?? '';
          _selectedDistrict = result['objectData'][0]['amphoeCode'] ?? '';
          _selectedSubDistrict = result['objectData'][0]['tambonCode'] ?? '';
          _selectedPostalCode = result['objectData'][0]['postnoCode'] ?? '';
          _selectedSex = result['objectData'][0]['sex'] ?? '';
        });
      }
      if (_selectedProvince != '') {
        getProvince();
        getDistrict();
        getSubDistrict();
        // setState(() {
        //   futureModel =
        getPostalCode();
        // });
      } else {
        // setState(() {
        //   futureModel =
        getProvince();
        // });
      }
    }
  }

  Future<dynamic> submitUpdateUser() async {
    var value = await storage.read(key: 'dataUserLoginOPEC');
    var user = json.decode(value!);
    user['imageUrl'] = _imageUrl ?? '';
    // user['prefixName'] = _selectedPrefixName ?? '';
    user['prefixName'] = txtPrefixName.text;
    user['firstName'] = txtFirstName.text;
    user['lastName'] = txtLastName.text;
    user['email'] = txtEmail.text;
    user['phone'] = txtPhone.text;

    user['birthDay'] = DateFormat("yyyyMMdd").format(
      DateTime(
        _selectedYear,
        _selectedMonth,
        _selectedDay,
      ),
    );
    user['sex'] = _selectedSex;
    user['address'] = txtAddress.text;
    user['soi'] = txtSoi.text;
    user['moo'] = txtMoo.text;
    user['road'] = txtRoad.text;
    user['tambon'] = '';
    user['amphoe'] = '';
    user['province'] = '';
    user['postno'] = '';
    user['tambonCode'] = _selectedSubDistrict ?? '';
    user['amphoeCode'] = _selectedDistrict;
    user['provinceCode'] = _selectedProvince ?? '';
    user['postnoCode'] = _selectedPostalCode;
    user['idcard'] = txtIdCard.text;
    user['officerCode'] = txtOfficerCode.text;
    user['linkAccount'] =
        user['linkAccount'] != null ? user['linkAccount'] : '';
    user['appleID'] = user['appleID'] != null ? user['appleID'] : "";

    final result = await postObjectData('m/v2/Register/update', user);

    if (result['status'] == 'S') {
      await storage.write(
        key: 'dataUserLoginOPEC',
        value: jsonEncode(result['objectData']),
      );

      await storage.write(
        key: 'profileImageUrl',
        value: _imageUrl,
      );
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => UserInformationPage(),
      //   ),
      // );

      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: CupertinoAlertDialog(
              title: new Text(
                'อัพเดตข้อมูลเรียบร้อยแล้ว',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Sarabun',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              content: Text(" "),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: new Text(
                    "ตกลง",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Sarabun',
                      color: Color(0xFF9A1120),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => HomePageV2(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                    // goBack();
                    // Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    } else {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: CupertinoAlertDialog(
              title: new Text(
                'อัพเดตข้อมูลไม่สำเร็จ',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Sarabun',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              content: new Text(
                result['message'],
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Sarabun',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: new Text(
                    "ตกลง",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Sarabun',
                      color: Color(0xFF9A1120),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  readStorage() async {
    var value = await storage.read(key: 'dataUserLoginOPEC');
    var user = json.decode(value!);

    if (user['code'] != '') {
      setState(() {
        _imageUrl = user['imageUrl'] ?? '';
        txtFirstName.text = user['firstName'] ?? '';
        txtLastName.text = user['lastName'] ?? '';
        txtEmail.text = user['email'] ?? '';
        txtPhone.text = user['phone'] ?? '';
        _selectedPrefixName = user['prefixName'];
        txtPrefixName.text = user['prefixName'] ?? '';
        _code = user['code'];
        _selectedProvince = user['provinceCode'] ?? '';
        _selectedDistrict = user['amphoeCode'] ?? '';
        _selectedSubDistrict = user['tambonCode'] ?? '';
        _selectedPostalCode = user['postnoCode'] ?? '';
      });

      if (user['birthDay'] != '') {
        var date = user['birthDay'];
        var year = date.substring(0, 4);
        var month = date.substring(4, 6);
        var day = date.substring(6, 8);
        DateTime todayDate = DateTime.parse(year + '-' + month + '-' + day);

        setState(() {
          _selectedYear = todayDate.year;
          _selectedMonth = todayDate.month;
          _selectedDay = todayDate.day;
          txtDate.text = DateFormat("dd-MM-yyyy").format(todayDate);
        });
      }

      if (_selectedProvince != '') {
        getProvince();
        getDistrict();
        getSubDistrict();
        getPostalCode();
        // setState(() {
        //   futureModel = getUser();
        // });
      } else {
        getProvince();
        // setState(() {
        //   futureModel = getUser();
        // });
      }
    }
  }

  card() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(padding: EdgeInsets.all(15), child: contentCard()),
    );
  }

  dialogOpenPickerDate() {
    dt_picker.DatePicker.showDatePicker(context,
        theme: dt_picker.DatePickerTheme(
          containerHeight: 210.0,
          itemStyle: TextStyle(
            fontSize: 16.0,
            color: Color(0xFF9A1120),
            fontWeight: FontWeight.normal,
            fontFamily: 'Sarabun',
          ),
          doneStyle: TextStyle(
            fontSize: 16.0,
            color: Color(0xFF9A1120),
            fontWeight: FontWeight.normal,
            fontFamily: 'Sarabun',
          ),
          cancelStyle: TextStyle(
            fontSize: 16.0,
            color: Color(0xFF9A1120),
            fontWeight: FontWeight.normal,
            fontFamily: 'Sarabun',
          ),
        ),
        showTitleActions: true,
        minTime: DateTime(1800, 1, 1),
        maxTime: DateTime(year, month, day), onConfirm: (date) {
      setState(
        () {
          _selectedYear = date.year;
          _selectedMonth = date.month;
          _selectedDay = date.day;
          txtDate.value = TextEditingValue(
            text: DateFormat("dd-MM-yyyy").format(date),
          );
        },
      );
    },
        currentTime: DateTime(
          _selectedYear,
          _selectedMonth,
          _selectedDay,
        ),
        locale: dt_picker.LocaleType.th);
  }

  contentCard() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          controller: scrollController,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          // mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 5.0),
            ),
            // Text(
            //   'ข้อมูลผู้ใช้งาน',
            //   style: TextStyle(
            //     fontSize: 18.00,
            //     fontFamily: 'Sarabun',
            //     fontWeight: FontWeight.w500,
            //     // color: Color(0xFFBC0611),
            //   ),
            // ),
            SizedBox(height: 5.0),
            // labelTextFormField('* ชื่อผู้ใช้งาน'),
            // textFormField(
            //   txtUsername,
            //   null,
            //   'ชื่อผู้ใช้งาน',
            //   'ชื่อผู้ใช้งาน',
            //   false,
            //   false,
            //   false,
            // ),
            // SizedBox(height: 15.0),
            // Text(
            //   'ข้อมูลส่วนตัว',
            //   style: TextStyle(
            //     fontSize: 18.00,
            //     fontFamily: 'Sarabun',
            //     fontWeight: FontWeight.w500,
            //     // color: Color(0xFFBC0611),
            //   ),
            // ),
            // labelTextFormField('* คำนำหน้า'),
            // textFormField(
            //   txtPrefixName,
            //   null,
            //   'คำนำหน้า',
            //   'คำนำหน้า',
            //   true,
            //   false,
            //   false,
            // ),
            labelTextFormField('* ชื่อ'),
            textFormField(
              txtFirstName,
              null,
              'ชื่อ',
              'ชื่อ',
              true,
              false,
              false,
            ),
            labelTextFormField('* นามสกุล'),
            textFormField(
              txtLastName,
              null,
              'นามสกุล',
              'นามสกุล',
              true,
              false,
              false,
            ),
            // labelTextFormField('* วันเดือนปีเกิด'),
            // GestureDetector(
            //   onTap: () => dialogOpenPickerDate(),
            //   child: AbsorbPointer(
            //     child: TextFormField(
            //       controller: txtDate,
            //       style: TextStyle(
            //         color: Color(0xFF9A1120),
            //         fontWeight: FontWeight.normal,
            //         fontFamily: 'Sarabun',
            //         fontSize: 15.0,
            //       ),
            //       decoration: InputDecoration(
            //         filled: true,
            //         fillColor: Color(0xFFEEBA33),
            //         contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
            //         hintText: "วันเดือนปีเกิด",
            //         border: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(10.0),
            //           borderSide: BorderSide.none,
            //         ),
            //         errorStyle: TextStyle(
            //           fontWeight: FontWeight.normal,
            //           fontFamily: 'Sarabun',
            //           fontSize: 10.0,
            //         ),
            //       ),
            //       // validator: (model) {
            //       //   if (model.isEmpty) {
            //       //     return 'กรุณากรอกวันเดือนปีเกิด.';
            //       //   }
            //       // },
            //     ),
            //   ),
            // ),
            // labelTextFormField('* รหัสประจำตัวประชาชน'),
            // textFormIdCardField(
            //   txtIdCard,
            //   'รหัสประจำตัวประชาชน',
            //   'รหัสประจำตัวประชาชน',
            //   true,
            // ),
            labelTextFormField('* เบอร์โทรศัพท์ (10 หลัก)'),
            textFormPhoneField(
              txtPhone,
              'เบอร์โทรศัพท์ (10 หลัก)',
              'เบอร์โทรศัพท์ (10 หลัก)',
              true,
              false,
            ),
            labelTextFormField('* อีเมล์'),
            textFormFieldNoValidator(
              txtEmail,
              'อีเมล์',
              false,
              false,
            ),
            // labelTextFormField('Line ID'),
            // textFormFieldNoValidator(
            //   txtLineID,
            //   'Line ID',
            //   true,
            //   false,
            // ),
            // labelTextFormField('* รหัสสมาชิก'),
            // textFormField(
            //   txtOfficerCode,
            //   null,
            //   'รหัสสมาชิก',
            //   'รหัสสมาชิก',
            //   true,
            //   false,
            //   false,
            // ),
            // labelTextFormField('* เพศ'),

            // new Container(
            //   width: 5000.0,
            //   padding: EdgeInsets.symmetric(
            //     horizontal: 5,
            //     vertical: 0,
            //   ),
            //   decoration: BoxDecoration(
            //     color: Color(0xFFEEBA33),
            //     borderRadius: BorderRadius.circular(
            //       10,
            //     ),
            //   ),
            //   child: DropdownButtonFormField(
            //     decoration: InputDecoration(
            //       errorStyle: TextStyle(
            //         fontWeight: FontWeight.normal,
            //         fontFamily: 'Sarabun',
            //         fontSize: 10.0,
            //       ),
            //       enabledBorder: UnderlineInputBorder(
            //         borderSide: BorderSide(
            //           color: Colors.white,
            //         ),
            //       ),
            //     ),
            //     validator: (value) =>
            //         // value == '' ||
            //         value == null ? 'กรุณาเลือกเพศ' : null,
            //     hint: Text(
            //       'เพศ',
            //       style: TextStyle(
            //         fontSize: 15.00,
            //         fontFamily: 'Sarabun',
            //       ),
            //     ),
            //     value: _selectedSex,
            //     onChanged: (newValue) {
            //       setState(() {
            //         _selectedSex = newValue;
            //       });
            //     },
            //     items: _itemSex.map((item) {
            //       return DropdownMenuItem(
            //         child: new Text(
            //           item['title'],
            //           style: TextStyle(
            //             fontSize: 15.00,
            //             fontFamily: 'Sarabun',
            //             color: Color(
            //               0xFF9A1120,
            //             ),
            //           ),
            //         ),
            //         value: item['code'],
            //       );
            //     }).toList(),
            //   ),
            // ),
            // labelTextFormField('ที่อยู่ปัจจุบัน'),
            // textFormFieldNoValidator(
            //   txtAddress,
            //   'ที่อยู่ปัจจุบัน',
            //   true,
            //   false,
            // ),
            // labelTextFormField('หมู่ที่'),
            // textFormFieldNoValidator(
            //   txtMoo,
            //   'หมู่ที่',
            //   true,
            //   false,
            // ),
            // labelTextFormField('ซอย'),
            // textFormFieldNoValidator(
            //   txtSoi,
            //   'ซอย',
            //   true,
            //   false,
            // ),
            // labelTextFormField('ถนน'),
            // textFormFieldNoValidator(
            //   txtRoad,
            //   'ถนน',
            //   true,
            //   false,
            // ),
            // new Container(
            //   width: 5000.0,
            //   padding: EdgeInsets.symmetric(
            //     horizontal: 5,
            //     vertical: 0,
            //   ),
            //   decoration: BoxDecoration(
            //     color: Color(0xFFEEBA33),
            //     borderRadius: BorderRadius.circular(
            //       10,
            //     ),
            //   ),
            //   child: _selectedPostalCode != ''
            //       ? DropdownButtonFormField(
            //           decoration: InputDecoration(
            //             errorStyle: TextStyle(
            //               fontWeight: FontWeight.normal,
            //               fontFamily: 'Sarabun',
            //               fontSize: 10.0,
            //             ),
            //             enabledBorder: UnderlineInputBorder(
            //               borderSide: BorderSide(
            //                 color: Colors.white,
            //               ),
            //             ),
            //           ),
            //           validator: (value) => value == '' || value == null
            //               ? 'กรุณาเลือกรหัสไปรษณีย์'
            //               : null,
            //           hint: Text(
            //             'รหัสไปรษณีย์',
            //             style: TextStyle(
            //               fontSize: 15.00,
            //               fontFamily: 'Sarabun',
            //             ),
            //           ),
            //           value: _selectedPostalCode,
            //           onChanged: (newValue) {
            //             setState(() {
            //               _selectedPostalCode = newValue;
            //             });
            //           },
            //           items: _itemPostalCode.map((item) {
            //             return DropdownMenuItem(
            //               child: new Text(
            //                 item['postCode'],
            //                 style: TextStyle(
            //                   fontSize: 15.00,
            //                   fontFamily: 'Sarabun',
            //                   color: Color(
            //                     0xFF9A1120,
            //                   ),
            //                 ),
            //               ),
            //               value: item['code'],
            //             );
            //           }).toList(),
            //         )
            //       : DropdownButtonFormField(
            //           decoration: InputDecoration(
            //             errorStyle: TextStyle(
            //               fontWeight: FontWeight.normal,
            //               fontFamily: 'Sarabun',
            //               fontSize: 10.0,
            //             ),
            //             enabledBorder: UnderlineInputBorder(
            //               borderSide: BorderSide(
            //                 color: Colors.white,
            //               ),
            //             ),
            //           ),
            //           validator: (value) => value == '' || value == null
            //               ? 'กรุณาเลือกรหัสไปรษณีย์'
            //               : null,
            //           hint: Text(
            //             'รหัสไปรษณีย์',
            //             style: TextStyle(
            //               fontSize: 15.00,
            //               fontFamily: 'Sarabun',
            //             ),
            //           ),
            //           onChanged: (newValue) {
            //             setState(() {
            //               _selectedPostalCode = newValue;
            //             });
            //           },
            //           items: _itemPostalCode.map((item) {
            //             return DropdownMenuItem(
            //               child: new Text(
            //                 item['postCode'],
            //                 style: TextStyle(
            //                   fontSize: 15.00,
            //                   fontFamily: 'Sarabun',
            //                   color: Color(
            //                     0xFF9A1120,
            //                   ),
            //                 ),
            //               ),
            //               value: item['code'],
            //             );
            //           }).toList(),
            //         ),
            // ),
            // Padding(
            //   padding: EdgeInsets.only(top: 10.0),
            // ),
            Center(
              child: Container(
                width: 200,
                margin: EdgeInsets.symmetric(vertical: 100.0),
                child: Material(
                  elevation: 2.0,
                  borderRadius: BorderRadius.circular(5.0),
                  color: Theme.of(context).primaryColor,
                  child: MaterialButton(
                    // minWidth: MediaQuery.of(context).size.width,
                    height: 40,
                    onPressed: () {
                      final form = _formKey.currentState;
                      if (form!.validate()) {
                        form.save();
                        submitUpdateUser();
                      }
                    },
                    child: new Text(
                      'บันทึกข้อมูล',
                      style: new TextStyle(
                        fontSize: 13.0,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Sarabun',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  rowContentButton(String urlImage, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Container(
            child: new Padding(
              padding: EdgeInsets.all(5.0),
              child: Image.asset(
                urlImage,
                height: 5.0,
                width: 5.0,
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Color(0xFF0B5C9E),
            ),
            width: 30.0,
            height: 30.0,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.63,
            margin: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Text(
              title,
              style: new TextStyle(
                fontSize: 12.0,
                color: Color(0xFF9A1120),
                fontWeight: FontWeight.normal,
                fontFamily: 'Sarabun',
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            child: Image.asset(
              "assets/icons/Group6232.png",
              height: 20.0,
              width: 20.0,
            ),
          ),
        ],
      ),
    );
  }

  _imgFromCamera() async {
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image!;
    });
    _upload();
  }

  _imgFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image!;
    });
    _upload();
  }

  void _upload() async {
    uploadImage(_image).then((res) {
      setState(() {
        _imageUrl = res;
      });
    }).catchError((err) {
      print(err);
    });
  }

  void _showPickerImage(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text(
                      'อัลบั้มรูปภาพ',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Sarabun',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(
                    'กล้องถ่ายรูป',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Sarabun',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void goBack() async {
    Navigator.pop(context, false);
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(
    //     builder: (context) => UserInformationPage(),
    //   ),
    //   (Route<dynamic> route) => false,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: header(context, goBack, title: 'แก้ไขข้อมูล', rightButton: null),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Text(
            'แก้ไขข้อมูล',
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.transparent,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
        backgroundColor: Color(0XFF224B45),
      ),
      backgroundColor: Color(0xFFF5F8FB),
      body: FutureBuilder<dynamic>(
        future: futureModel,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Container(
              color: Colors.white,
              child: dialogFail(context),
            ));
          } else {
            return Container(
              child: ListView(
                controller: scrollController,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Center(
                        child: Container(
                          width: 96.0,
                          height: 96.0,
                          margin: EdgeInsets.only(top: 30.0),
                          padding: EdgeInsets.all(_imageUrl != '' ? 0.0 : 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(48),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              _showPickerImage(context);
                            },
                            child: _imageUrl != ''
                                ? CircleAvatar(
                                    backgroundColor: Colors.black,
                                    backgroundImage: _imageUrl != ''
                                        ? NetworkImage(_imageUrl)
                                        : null,
                                  )
                                : Container(
                                    padding: EdgeInsets.all(10.0),
                                    child: Image.asset(
                                      'assets/images/user_not_found.png',
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 31.0,
                          height: 31.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Theme.of(context).primaryColor),
                          margin: EdgeInsets.only(top: 90.0, left: 70.0),
                          child: Container(
                            padding: EdgeInsets.all(5.0),
                            child: Image.asset('assets/logo/icons/Group37.png'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    // color: Colors.white,
                    child: contentCard(),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
