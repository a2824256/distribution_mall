import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mall/constant/string.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mall/widgets/mall_icon.dart';
import 'package:mall/service/user_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mall/entity/user_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mall/utils/navigator_util.dart';
import 'package:mall/event/login_event.dart';
import 'package:mall/utils/shared_preferences_util.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:mall/api/api.dart';
import 'dart:async';
class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController _accountTextControl = TextEditingController();
  TextEditingController _passwordTextControl = TextEditingController();
  UserService userService = UserService();
  UserEntity userEntity;
  bool _autovalidator = false;
  final registerFormKey = GlobalKey<FormState>();
  String _result = "无";
  String code;
  StreamSubscription<fluwx.WeChatAuthResponse> _wxlogin;
  @override
  void initState() {
    super.initState();
    listenerWeChatResponse();

  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _wxlogin.cancel();
    fluwx.responseFromAuth.drain();
    code = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrangeAccent,
      body: SafeArea(
        child: Container(
            alignment: Alignment.centerLeft,
            child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(30.0), 0,
                        ScreenUtil().setWidth(30.0), 0),
                    height: ScreenUtil.instance.setHeight(400.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Form(
                      key: registerFormKey,
                      child: Column(
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(
                                  top: ScreenUtil.instance.setHeight(25.0))),
//                          Container(
//                            margin:
//                            EdgeInsets.all(ScreenUtil.instance.setWidth(30.0)),
//                            child: TextFormField(
//                              maxLines: 1,
//                              maxLength: 11,
//                              autovalidate: _autovalidator,
//                              keyboardType: TextInputType.phone,
//                              validator: _validatorAccount,
//                              decoration: InputDecoration(
//                                icon: Icon(
//                                  Icons.account_circle,
//                                  color: Colors.deepOrangeAccent,
//                                  size: ScreenUtil.instance.setWidth(60.0),
//                                ),
//                                hintText: Strings.ACCOUNT_HINT,
//                                hintStyle: TextStyle(
//                                    color: Colors.grey,
//                                    fontSize: ScreenUtil.instance.setSp(28.0)),
//                                labelStyle: TextStyle(
//                                    color: Colors.black54,
//                                    fontSize: ScreenUtil.instance.setSp(28.0)),
//                                labelText: Strings.ACCOUNT,
//                              ),
//                              controller: _accountTextControl,
//                            ),
//                          ),
//                          Container(
//                            margin:
//                            EdgeInsets.all(ScreenUtil.instance.setWidth(30.0)),
//                            child: TextFormField(
//                              maxLines: 1,
//                              maxLength: 12,
//                              obscureText: true,
//                              autovalidate: _autovalidator,
//                              validator: __validatorPassWord,
//                              decoration: InputDecoration(
//                                icon: Icon(
//                                  MallIcon.PASS_WORD,
//                                  color: Colors.deepOrangeAccent,
//                                  size: ScreenUtil.instance.setWidth(60.0),
//                                ),
//                                hintText: Strings.PASSWORD_HINT,
//                                hintStyle: TextStyle(
//                                    color: Colors.grey,
//                                    fontSize: ScreenUtil.instance.setSp(28.0)),
//                                labelStyle: TextStyle(
//                                    color: Colors.black54,
//                                    fontSize: ScreenUtil.instance.setSp(28.0)),
//                                labelText: Strings.PASSWORD,
//                              ),
//                              controller: _passwordTextControl,
//                            ),
//                          ),
//                          Container(
//                              margin: EdgeInsets.all(
//                                  ScreenUtil.instance.setWidth(30.0)),
//                              child: SizedBox(
//                                height: ScreenUtil.instance.setHeight(80.0),
//                                width: ScreenUtil.instance.setWidth(600.0),
//                                child: RaisedButton(
//                                  onPressed: _login,
//                                  color: Colors.deepOrangeAccent,
//                                  child: Text(
//                                    Strings.LOGIN,
//                                    style: TextStyle(
//                                        color: Colors.white,
//                                        fontSize: ScreenUtil.instance.setSp(28.0)),
//                                  ),
//                                ),
//                              )),
                          Container(
                              margin: EdgeInsets.all(
                                  ScreenUtil.instance.setWidth(60.0)),
                              child: InkWell(
                                onTap: () {
                                  //todo 微信登录
                                  _weChartLogin();
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text(
                                              '欢迎使用,'+Strings.TITLE,
                                            style: TextStyle(
                                              color: Colors.deepOrange,
                                              fontSize: 20
                                            ),
                                          ),
                                        ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Icon(
                                        MallIcon.WX_SESSION,
                                        color: Colors.deepOrange,
                                        size: 30,
                                      )
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        "微信登录",
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .copyWith(
                                            color: Colors.deepOrange, fontSize: 24),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                          ),


                          ///微信登录按钮
//                          Container(
//                            margin:
//                            EdgeInsets.all(ScreenUtil.instance.setWidth(20.0)),
//                            alignment: Alignment.centerRight,
//                            child: InkWell(
//                              onTap: () => _weChartLogin(),
//                              child: Text(
//                                Strings.NOW_REGISTER,
//                                style: TextStyle(
//                                    color: Colors.deepOrangeAccent,
//                                    fontSize: ScreenUtil.instance.setSp(24.0)),
//                              ),
//                            ),
//                          )
                        ],
                      ),
                    ),
                  ),
                ))),
      ),
    );
  }

  _register() {
    NavigatorUtils.goRegister(context);
  }

  String _validatorAccount(String value) {
    if (value == null || value.length < 11) {
      return Strings.ACCOUNT_RULE;
    }
    return null;
  }

  String __validatorPassWord(String value) {
    if (value == null || value.length < 6) {
      return Strings.PASSWORD_HINT;
    }
    return null;
  }

  _login() {
    if (registerFormKey.currentState.validate()) {
      registerFormKey.currentState.save();
      Map<String, dynamic> map = Map();
      map.putIfAbsent("username", () => _accountTextControl.text.toString());
      map.putIfAbsent("password", () => _passwordTextControl.text.toString());
      userService.login(map, (success) {
        print(success);
        userEntity = success;
        _saveUserInfo();
        _showToast(Strings.LOGIN_SUCESS);
//        Provider.of<UserInfoModel>(context, listen: true)
//            .updateInfo(userEntity);
        loginEventBus.fire(LoginEvent(true,
            url: userEntity.userInfo.avatarUrl,
            nickName: userEntity.userInfo.nickName));
        Navigator.pop(context);
      }, (onFail) {
        print(onFail);
        _showToast(onFail);
      });
    } else {
      setState(() {
        _autovalidator = true;
      });
    }
  }

  _showToast(message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: ScreenUtil.instance.setSp(28.0));
  }

  _saveUserInfo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    SharedPreferencesUtils.token = userEntity.token;
    await sharedPreferences.setString(Strings.TOKEN, userEntity.token);
    await sharedPreferences.setString(
        Strings.HEAD_URL, userEntity.userInfo.avatarUrl);
    await sharedPreferences.setString(
        Strings.NICK_NAME, userEntity.userInfo.nickName);
    await sharedPreferences.setString(
        'unionid', '');
    await sharedPreferences.setString(
        'username', '');
  }

  ///微信登录
  _weChartLogin() async {
    fluwx.sendAuth(scope: "snsapi_userinfo", state: "wechat_sdk_demo_test");
  }

  void getOpenId(String code) async{
    String _url = Api.DOMAIN+"/index/index/get_openid?code=" + code;
    var h = HttpClient();
    var request = await h.getUrl(Uri.parse(_url));
    var response = await request.close();
    var data = await Utf8Decoder().bind(response).join();
    Map<String, dynamic> result = json.decode(data);
    try{
      if(result['errno'] != 0){
        throw('');
      }
      userEntity = UserEntity.fromJson(result['data']);
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      SharedPreferencesUtils.token = userEntity.token;
      await sharedPreferences.setString(Strings.TOKEN, userEntity.token);
      await sharedPreferences.setString(
          Strings.HEAD_URL, result['data']['userInfo']['avatarUrl']);
      await sharedPreferences.setString(
          Strings.NICK_NAME, result['data']['userInfo']['nickName']);
      await sharedPreferences.setString(
          'username', result['data']['userInfo']['username']);
      await sharedPreferences.setString(
          'unionid', result['data']['unionid']);
      await sharedPreferences.setInt(
          'userid', result['data']['userInfo']['userid']);
      Navigator.popAndPushNamed(context, '/home');
      _showToast(Strings.LOGIN_SUCESS);
      loginEventBus.fire(LoginEvent(true,
          url: result['data']['userInfo']['avatarUrl'],
          nickName: result['data']['userInfo']['nickName']));
    }catch(e){
//      print('error!!!!!!!!!!!!');
//      print(e.toString());
//      print(result);
      _showToast('微信提示:请勿频繁授权,code:'+code);
      Navigator.pop(context);
    }
  }

  void listenerWeChatResponse() {
    _wxlogin = fluwx.responseFromAuth.listen((data) {
      setState(() {
        code = data.code;
        print('~~~~~~~~');
        print(data.code);
        getOpenId(code);
      });
    });
  }
}
