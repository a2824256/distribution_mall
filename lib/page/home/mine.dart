import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:mall/api/api.dart';
import 'package:mall/constant/string.dart';
import 'package:mall/event/login_event.dart';
import 'package:mall/page/mine/person.dart';
import 'package:mall/service/user_service.dart';
import 'package:mall/utils/http_util.dart';
import 'package:mall/utils/navigator_util.dart';
import 'package:mall/utils/shared_preferences_util.dart';
import 'package:mall/utils/toast_util.dart';
import 'package:mall/widgets/icon_text_arrow.dart';
import 'package:mall/widgets/mall_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MineView extends StatefulWidget {
  @override
  _MineViewState createState() => _MineViewState();
}

class _MineViewState extends State<MineView> {
  bool isLogin = false;
  var imageHeadUrl;
  var nickName;
  UserService _userService = UserService();
  bool isLogout = false;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  @override
  void deactivate() {
    var bool = ModalRoute.of(context).isCurrent;
    if (bool) {
      _refreshEvent();
      _getUserInfo();
    }
  }

  _refreshEvent() {
    loginEventBus.on<LoginEvent>().listen((LoginEvent loginEvent) {
      if (loginEvent.isLogin) {
        setState(() {
          isLogin = true;
          imageHeadUrl = loginEvent.url;
          nickName = loginEvent.nickName;
        });
      } else {
        setState(() {
          isLogin = false;
        });
      }
    });
  }

  _getUserInfo() {
    SharedPreferencesUtils.getToken().then((token) {
      if (token != null) {
        setState(() {
          isLogin = true;
        });
        SharedPreferencesUtils.getImageHead().then((imageHeadAddress) {
          setState(() {
            imageHeadUrl = imageHeadAddress;
          });
        });
        SharedPreferencesUtils.getUserName().then((name) {
          setState(() {
            nickName = name;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _refreshEvent();
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.MINE),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: ScreenUtil.getInstance().setHeight(160.0),
            width: double.infinity,
            color: Colors.deepOrangeAccent,
            alignment: Alignment.center,
            child: isLogin
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: ScreenUtil.getInstance().setWidth(100),
                        height: ScreenUtil.getInstance().setHeight(100),
                        margin: EdgeInsets.only(
                            left: ScreenUtil.getInstance().setWidth(30.0)),
                        child: CircleAvatar(
                          radius: ScreenUtil.getInstance().setWidth(50),
                          foregroundColor: Colors.deepOrangeAccent,
                          backgroundImage: NetworkImage(
                            imageHeadUrl,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: ScreenUtil.getInstance().setWidth(10.0)),
                      ),
                      Text(
                        nickName,
                        style: TextStyle(
                            fontSize: ScreenUtil.getInstance().setSp(26.0),
                            color: Colors.white),
                      ),
//                      Text(
//                        '         积分：0',
//                        style: TextStyle(
//                            fontSize: ScreenUtil.getInstance().setSp(20.0),
//                            color: Colors.white),
//                      ),
                      _IntegralText(
                        name: nickName,
                      ),
                      Expanded(
                        child: InkWell(
                            onTap: () => _loginOutDialog(),
                            child: Offstage(
                              offstage: !isLogin,
                              child: Container(
                                padding: EdgeInsets.only(
                                    right:
                                        ScreenUtil.getInstance().setWidth(30)),
                                alignment: Alignment.centerRight,
                                child: Text(
                                  Strings.LOGIN_OUT,
                                  style: TextStyle(
                                      fontSize:
                                          ScreenUtil.getInstance().setSp(26),
                                      color: Colors.white),
                                ),
                              ),
                            )),
                      ),
                    ],
                  )
                : InkWell(
                    onTap: () => _toLogin(),
                    child: Text(
                      Strings.CLICK_LOGIN,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil.getInstance().setSp(30.0)),
                    ),
                  ),
          ),
          Padding(
            padding:
                EdgeInsets.only(top: ScreenUtil.getInstance().setHeight(20.0)),
          ),
          IconTextArrowView(Icons.account_box, '个人信息', Colors.green, person),
          Divider(
            height: ScreenUtil.getInstance().setHeight(1.0),
            color: Color(0xffd3d3d3),
          ),
          IconTextArrowView(
              MallIcon.ORDER, Strings.ORDER, Colors.deepPurpleAccent, order),
          Divider(
            height: ScreenUtil.getInstance().setHeight(1.0),
            color: Color(0xffd3d3d3),
          ),
          IconTextArrowView(
              MallIcon.COLLECTION, Strings.COLLECTION, Colors.red, collect),
          Divider(
            height: ScreenUtil.getInstance().setHeight(1.0),
            color: Color(0xffd3d3d3),
          ),
          IconTextArrowView(
              MallIcon.ADDRESS, Strings.ADDRESS, Colors.amber, address),
          Divider(
            height: ScreenUtil.getInstance().setHeight(1.0),
            color: Color(0xffd3d3d3),
          ),
          IconTextArrowView(
              MallIcon.FOOTPRINT, Strings.FOOTPRINT, Colors.pink, footprint),
          Divider(
            height: ScreenUtil.getInstance().setHeight(1.0),
            color: Color(0xffd3d3d3),
          ),
          IconTextArrowView(MallIcon.FEED_BACK, Strings.FEED_BACK,
              Colors.blueAccent, feedbackCallback),
          Divider(
            height: ScreenUtil.getInstance().setHeight(1.0),
            color: Color(0xffd3d3d3),
          ),
          //TODO 分销关系
          IconTextArrowView(MallIcon.ABOUT_US, '分销关系', Colors.teal, aboutUs),
          Divider(
            height: ScreenUtil.getInstance().setHeight(1.0),
            color: Color(0xffd3d3d3),
          ),
          // 分享下载地址
          IconTextArrowView(Icons.mobile_screen_share, '分享下载地址', Colors.red,
              shareDownloadUrl),
          Divider(
            height: ScreenUtil.getInstance().setHeight(1.0),
            color: Color(0xffd3d3d3),
          ),
        ],
      ),
    );
  }

  _loginOutDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              Strings.TIPS,
              style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(30),
                  color: Colors.black54),
            ),
            content: Text(
              Strings.LOGIN_OUT_TIPS,
              style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(30),
                  color: Colors.black54),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  Strings.CANCEL,
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              FlatButton(
                onPressed: () => _loginOut(),
                child: Text(
                  Strings.CONFIRM,
                  style: TextStyle(color: Colors.deepOrangeAccent),
                ),
              )
            ],
          );
        });
  }

  _loginOut() async {
    _userService.loginOut((success) {
      loginEventBus.fire(LoginEvent(false));
//      loginEventBus.destroy();
    }, (error) {
      loginEventBus.fire(LoginEvent(false));
//      loginEventBus.destroy();
      ToastUtil.showToast(error);
    });
    setState(() {
      isLogin = false;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    SharedPreferencesUtils.token = null;
    prefs.remove("X-Litemall-Token");
    Navigator.pop(context);
  }

  void feedbackCallback() {
    if (isLogin) {
      NavigatorUtils.goFeedback(context);
    } else {
      _toLogin();
    }
  }

  void person() {
    if (isLogin) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PersonView();
      }));
    } else {
      _toLogin();
    }
  }

  void footprint() {
    if (isLogin) {
      NavigatorUtils.goFootprint(context);
    } else {
      _toLogin();
    }
  }

  void collect() {
    if (isLogin) {
      NavigatorUtils.goCollect(context);
    } else {
      _toLogin();
    }
  }

  void address() {
    if (isLogin) {
      NavigatorUtils.goAddress(context);
    } else {
      _toLogin();
    }
  }

  void aboutUs() {
    if (isLogin) {
      NavigatorUtils.goAboutUs(context);
    } else {
      _toLogin();
    }
  }

  void order() {
    if (isLogin) {
      NavigatorUtils.goOrder(context);
    } else {
      _toLogin();
    }
  }

  void shareDownloadUrl() async {
    if (isLogin) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String unionid = sharedPreferences.getString('unionid');
      String nickname = sharedPreferences.getString(Strings.NICK_NAME);
      var scene = await showShareBottomSheetDialog(context);
      if (scene != null) {
        fluwx.shareToWeChat(fluwx.WeChatShareWebPageModel(
          webPage: "http://api.sxyinsite.com/index/api/wx_login?mobile=" +
              nickname +
              "&unionid=" +
              unionid,
          thumbnail: "assets://images/ysw.jpg",
          scene: scene,
          title: "盈商网",
        ));
      }
    } else {
      _toLogin();
    }
  }

  _toLogin() {
    NavigatorUtils.goLogin(context);
  }
}

/// 展示分享对话框
///
Future<fluwx.WeChatScene> showShareBottomSheetDialog(BuildContext context) {
  return showDialog<fluwx.WeChatScene>(
    context: context,
    builder: (context) {
      return SimpleDialog(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      Navigator.pop(context, fluwx.WeChatScene.SESSION),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        MallIcon.WX_SESSION,
                        size: 48,
                        color: Colors.green,
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text("微信"),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      Navigator.pop(context, fluwx.WeChatScene.TIMELINE),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        MallIcon.WX_TIMELINE,
                        size: 48,
                        color: Colors.green,
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text("朋友圈"),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      );
    },
  );
}

class _IntegralText extends StatelessWidget {
  final String name;

  const _IntegralText({Key key, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getIntegral(),
        builder: (context, shot) {
          if (shot.hasData && shot.data != null) {
            return Text(
              '         积分：${shot.data['data']['integral']}',
              style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(20.0),
                  color: Colors.white),
            );
          }
          return Container();
        });
  }

  Future getIntegral() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int userid = sharedPreferences.getInt('userid');
    print('userid222:${userid}');
    return HttpUtil.instance.get(Api.DOMAIN + "/index/index/getIntegral",
        parameters: {"userid": userid});
  }
}
