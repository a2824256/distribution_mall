import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mall/api/api.dart';
import 'package:mall/constant/string.dart';
import 'package:mall/utils/http_util.dart';
import 'package:mall/utils/toast_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdatePersonalInfoView extends StatefulWidget {
  String nickname;
  String username;
  String gender;
  int userId;

  UpdatePersonalInfoView(
      this.nickname, this.username, this.gender, this.userId);

  @override
  _UpdatePersonalInfoViewState createState() => _UpdatePersonalInfoViewState();
}

class _UpdatePersonalInfoViewState extends State<UpdatePersonalInfoView> {
  TextEditingController _nicknameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  String _nickname = "";
  String _username = "";
  int _userId = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nicknameController.text = widget.nickname;
    _usernameController.text = widget.username;
    setState(() {
      _nickname = widget.nickname;
      _username = widget.username;
      _userId = widget.userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('修改个人信息'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          TextField(
            autofocus: true,
            decoration: InputDecoration(
                labelText: "用户名", prefixIcon: Icon(Icons.person)),
            onChanged: (s) => _nickname = s,
            controller: _nicknameController,
          ),
          TextField(
            autofocus: true,
            decoration: InputDecoration(
                labelText: "电话号码", prefixIcon: Icon(Icons.phone)),
            onChanged: (s) => _username = s,
            controller: _usernameController,
          ),
//          Container(
//            padding: EdgeInsets.only(top: 8, bottom: 8),
//            child: Row(
//              children: <Widget>[
//                Padding(
//                  padding: EdgeInsets.only(left: 10),
//                ),
//                Icon(
//                  Icons.pregnant_woman,
//                  size: 30,
//                  color: Colors.grey,
//                ),
//                Checkbox(
//                  value: false,
//                ),
//                Text('男'),
//                Checkbox(
//                  value: false,
//                ),
//                Text('女'),
//              ],
//            ),
//          ),
          Divider(
            color: Colors.grey[800],
            height: ScreenUtil.instance.setHeight(5.0),
          ),
          SizedBox(
            height: 16,
          ),
          Center(
              child: InkWell(
            onTap: update,
            child: Chip(
                label: Text(
                  '            修改            ',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil.instance.setSp(30.0)),
                ),
                backgroundColor: Colors.deepOrangeAccent),
          ))
        ],
      ),
    );
  }

  ///提现
  void update() async {
    if (_nickname.isEmpty || _username.isEmpty || _username == '无') {
      ToastUtil.showToast("请检查输入信息");
      return;
    }
    var result = await HttpUtil.instance
        .post(Api.DOMAIN + "/index/index/updatePersonalInfo", parameters: {
      "nickname": _nickname,
      "username": _username,
      "userid": _userId,
    });
    print(result);
    if (result['errno'] == 0) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.setString(Strings.NICK_NAME, _nickname);
      await sharedPreferences.setString('username', _username);

      ///成功
      ToastUtil.showToast(result['errmsg']);
      Navigator.pop(context);
    } else {
      print(result);

      ///失败
      ToastUtil.showToast(result['errmsg']);
    }
  }
}
