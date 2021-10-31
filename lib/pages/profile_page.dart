import 'package:flutter/material.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/login_page.dart';
import 'package:flutter_app_chat/services/auth_services.dart';
import 'package:flutter_app_chat/services/database.dart';
import 'package:flutter_app_chat/shared_widgets/back_button.dart';
import 'package:flutter_app_chat/values/app_colors.dart';
import 'package:flutter_app_chat/values/app_styles.dart';

class ProfilePage extends StatefulWidget {
  final UserInfor infor;
  const ProfilePage({Key? key, required this.infor}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();

  bool editMode = false;
  late UserInfor infor;
  initField(infor) {
    _nameController.text = infor.name;
    _emailController.text = infor.email;
    _phoneController.text = infor.phone;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    infor = widget.infor;
    print(infor.name);
    initField(infor);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: _profileBar(),
        body: Column(
          children: [
            Container(
              height: size.height / 3,
              child: Stack(
                children: [
                  Positioned(
                    bottom: 50,
                    width: size.width,
                    height: size.height / 3 - 50,
                    child: Container(
                      color: Colors.blue.withOpacity(0.2),
                    ),
                  ),
                  _avatar(size),
                  _editInfor(),
                ],
              ),
            ),
            _detailInfor(size),
          ],
        ),
      ),
    );
  }

  AppBar _profileBar() {
    return AppBar(
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: CustomBackButton(onTap: back),
      ),
      toolbarHeight: MediaQuery.of(context).size.height / 13.8,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        Container(
          padding: const EdgeInsets.all(4),
          child: InkWell(
            onTap: logOut,
            borderRadius: BorderRadius.circular(50),
            child: Padding(
              padding: EdgeInsets.fromLTRB(5, 4, 3, 4),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(
                  Icons.logout,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _detailInfor(Size size) {
    return Container(
      height: size.height * 2.0 / 3,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _input('Name', infor.name, _nameController),
                _input('Email', infor.email, _emailController),
                _input('Phone', infor.phone, _phoneController),
              ],
            ),
            editMode
                ? Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [_savebtn(size), _cancelBtn(size)],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, String text, TextEditingController controller) {
    bool enable = label == 'Email' ? false : editMode;
    return TextFormField(
      maxLines: 1,
      controller: controller,
      enabled: enable,
      textInputAction: TextInputAction.done,
      keyboardType:
          label == 'Phone' ? TextInputType.number : TextInputType.text,
      style: AppStyles.fillStyle
          .copyWith(color: enable ? AppColors.primary : Colors.grey.shade600),
      decoration: InputDecoration(
        enabled: editMode,
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        prefix: Container(
            width: 100,
            child: Text(
              label,
              style: AppStyles.fillStyle.copyWith(
                  color: enable ? AppColors.primary : AppColors.grey_text),
            )),
        prefixIcon: Icon(
            label == 'Phone'
                ? Icons.phone
                : (label == 'Name' ? Icons.child_care : Icons.email),
            color: enable ? AppColors.primary : AppColors.grey_text),
        border: !enable
            ? InputBorder.none
            : UnderlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                borderSide: BorderSide(color: AppColors.primary, width: 1.0)),
        enabledBorder: !enable
            ? InputBorder.none
            : UnderlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                borderSide: BorderSide(color: AppColors.primary, width: 1.0)),
      ),
    );
  }

  Widget _savebtn(Size size) {
    return Container(
      width: size.width / 3,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            //padding: const EdgeInsets.symmetric(vertical: 12),
            fixedSize: Size(double.maxFinite, double.infinity),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
            primary: AppColors.primary),
        onPressed: update,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Save',
            style: AppStyles.textButton.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _cancelBtn(Size size) {
    return Container(
      width: size.width / 3,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            //padding: const EdgeInsets.symmetric(vertical: 12),
            fixedSize: Size(double.maxFinite, double.infinity),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
            primary: Colors.grey.shade400),
        onPressed: cancel,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Cancel',
            style: AppStyles.textButton.copyWith(color: Colors.black45),
          ),
        ),
      ),
    );
  }

  Widget _editInfor() {
    return Positioned(
      right: 3,
      bottom: 53,
      height: 32,
      child: InkWell(
        onHover: (onHover) {},
        onTap: _editInfo,
        borderRadius: BorderRadius.circular(15),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(
                Icons.edit,
                color: Colors.black,
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 10),
              child: Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(Size size) {
    return Positioned(
      left: size.width / 2 - 50,
      bottom: 0,
      width: 100,
      height: 100,
      child: InkWell(
        onTap: _changeAvt,
        borderRadius: BorderRadius.circular(50),
        child: CircleAvatar(
          child: Text(widget.infor.name.substring(0, 1).toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 40)),
        ),
      ),
    );
  }

  void back() {
    Navigator.pop(context);
  }

  void logOut() {
    AuthServices authServices = new AuthServices();
    authServices.signOut();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => LoginPage()), (route) => false);
  }

  void _editInfo() {
    setState(() {
      editMode = !editMode;
    });
    print('edit');
  }

  void _changeAvt() {
    print('change avatar');
  }

  void update() {
    UserInfor newInfor = new UserInfor(
        email: infor.email,
        name: _nameController.text,
        avatar: infor.avatar,
        phone: _phoneController.text);
    DatabaseServices databaseServices = new DatabaseServices();
    databaseServices.updateInfor(newInfor);
    setState(() {
      editMode = !editMode;
    });
  }

  void cancel() {
    initField(infor);
    setState(() {
      editMode = !editMode;
    });
  }
}
