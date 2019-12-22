import 'package:flutter/material.dart';
import 'package:mall/constant/string.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mall/page/mine/update_person.dart';
import 'package:mall/utils/http_util.dart';
import 'package:mall/utils/toast_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'person_row.dart';
import 'package:mall/api/api.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:convert';

class PersonView extends StatefulWidget {
  @override
  _PersonViewState createState() => _PersonViewState();
}

class _PersonViewState extends State<PersonView> {
  bool isLogin = false;
  var imageHeadUrl;
  var nickName;
  String username = '无';
  var gender = '无';
  bool isLogout = false;
  int userId = 0;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  @override
  void deactivate() {
    var bool = ModalRoute.of(context).isCurrent;
    if (bool) {
      _getUserInfo();
    }
  }

  _getUserInfoNetWork() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int userid = await sharedPreferences.getInt('userid');
    String _url = Api.DOMAIN + '/index/index/personalInfo?userid=${userid}';
    print(_url);
    var response = await HttpUtil.instance.post(_url, parameters: {});
    print(response);
    if (response['errno'] == 0) {
      setState(() {
        gender = response['data']['gender'];
        username = response['data']['username'];
        userId = response['data']['id'];
      });
    } else {
      ToastUtil.showToast('获取信息失败');
    }
  }

  _jump2Update() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return UpdatePersonalInfoView(nickName, username, gender, userId);
    }));
  }

  Future getImage() async {
    print('click');
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    _upLoadImage(image);//上传图片
  }

  _upLoadImage(File image) async {
    String path = image.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    FormData formData = new FormData.from({
      "file": new UploadFileInfo(new File(path), name),
      "userid": userId,
    });
    Dio dio = new Dio();
    var response = await dio.post<String>(Api.DOMAIN+"/index/index/uploadPic", data: formData);
    Map<String, dynamic> result = json.decode(response.toString());
    if (response.statusCode == 200) {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setString(
          Strings.HEAD_URL, result['imgpath']);
      setState(() {
        print(result['imgpath']);
        imageHeadUrl = result['imgpath'];
      });
      ToastUtil.showToast('上传成功');
    }
  }

  _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      imageHeadUrl = prefs.get(Strings.HEAD_URL);
      nickName = prefs.get(Strings.NICK_NAME);
    });
    _getUserInfoNetWork();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('个人信息'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding:
                EdgeInsets.only(top: ScreenUtil.getInstance().setHeight(20.0)),
          ),
          InkWell(
            onTap: (){
              getImage();
            },
              child: Container(
            padding: EdgeInsets.all(20.0),
            child: Container(
              height: ScreenUtil.instance.setHeight(80.0),
              child: Row(
                children: <Widget>[
                  Text(
                    '头像',
                    style: TextStyle(fontSize: ScreenUtil.instance.setSp(26.0)),
                  ),
                  Expanded(
                      child: Container(
                    padding: EdgeInsets.only(left: 20.0),
                    alignment: Alignment.centerRight,
                    child: Text(
                      '',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: ScreenUtil.instance.setSp(26.0)),
                    ),
                  )),
                  Expanded(
                      child: Container(
                    padding: EdgeInsets.only(right: 10.0),
                    alignment: Alignment.centerRight,
                    child: Container(
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
                  )),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: ScreenUtil.getInstance().setWidth(30),
                  )
                ],
              ),
            ),
          )),
          Divider(
            height: ScreenUtil.getInstance().setHeight(1.0),
            color: Color(0xffd3d3d3),
          ),
          InkWell(
            onTap: () {
              _jump2Update();
            },
            child: PersonRowView('姓名', nickName),
          ),
          Divider(
            height: ScreenUtil.getInstance().setHeight(1.0),
            color: Color(0xffd3d3d3),
          ),
          InkWell(
            onTap: () {
              _jump2Update();
            },
            child: PersonRowView('手机号', username ?? '无'),
          ),
          Divider(
            height: ScreenUtil.getInstance().setHeight(1.0),
            color: Color(0xffd3d3d3),
          ),
          Container(
            padding: EdgeInsets.all(20.0),
            child: Container(
              height: ScreenUtil.instance.setHeight(80.0),
              child: Row(
                children: <Widget>[
                  Text(
                    '性别',
                    style: TextStyle(
                        fontSize: ScreenUtil.instance.setSp(26.0)),
                  ),

                  Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 20.0),
                        alignment: Alignment.centerRight,
                        child: Text(
                          '',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: ScreenUtil.instance.setSp(26.0)),
                        ),
                      )),
                  Expanded(
                      child: Container(
                        padding: EdgeInsets.only(right: 10.0),
                        alignment: Alignment.centerRight,
                        child: Text(
                          gender,
                          style: TextStyle(
                              color: Colors.black45,
                              fontSize: ScreenUtil.instance.setSp(26.0)),
                        ),
                      )),
//                  Icon(
//                    Icons.arrow_forward_ios,
//                    color: Colors.grey,
//                    size: ScreenUtil.getInstance().setWidth(30),
//                  )
                ],
              ),
            ),
          ),
          Divider(
            height: ScreenUtil.getInstance().setHeight(1.0),
            color: Color(0xffd3d3d3),
          ),
        ],
      ),
    );
  }
}
