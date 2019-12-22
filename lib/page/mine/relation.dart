import 'package:flutter/material.dart';
import 'package:mall/constant/string.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mall/widgets/item_text.dart';
import 'package:mall/widgets/divider_line.dart';
import 'package:mall/utils/http_util.dart';
import 'package:mall/entity/user_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io' as H;
import 'package:mall/api/api.dart';

class RelationView extends StatefulWidget {
  @override
  _RelationViewState createState() => _RelationViewState();
}

class _RelationViewState extends State<RelationView> {
  Map<String, dynamic> result;

  @override
  void initState() {
    super.initState();
  }

  Future getData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int userid = await sharedPreferences.getInt('userid');

    var h = H.HttpClient();
    String url =
        Api.DOMAIN + "/index/mall/getUserRelation_app?userid=${userid}";
    print(url);
    var request = await h.getUrl(Uri.parse(url));
    var response = await request.close();
    var data = await Utf8Decoder().bind(response).join();
    result = json.decode(data);
    print("!!!!!!!!!");
    print(result);
  }

  Widget _supRelation() {
    try {
      return ItemTextView(result['sup']['nickname'], result['sup']['add_time']);
    } catch (e) {
      return DividerLineView();
    }
  }

  List<Widget> _subRelation() {
    try {
      List<Widget> list = List();
      for (int i = 0; i < result['sub'].length; i++) {
        list.add(ItemTextView(
            result['sub'][i]['nickname'], result['sub'][i]['add_time']));
        list.add(DividerLineView());
      }
      return list;
    } catch (e) {
      return [DividerLineView()];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('分销关系'),
          centerTitle: true,
        ),
        body: FutureBuilder(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot snapShot) {
            return Container(
              margin: EdgeInsets.all(ScreenUtil.instance.setWidth(20.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text('上级关系'),
                  ),
                  Padding(
                      padding:
                          EdgeInsets.all(ScreenUtil.instance.setHeight(10.0))),
                  DividerLineView(),
//                Column(
//                  children: _supRelation(),
//                ),
                  _supRelation(),
                  DividerLineView(),
                  Container(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text('下级关系'),
                  ),
                  Padding(
                      padding:
                          EdgeInsets.all(ScreenUtil.instance.setHeight(10.0))),
                  Column(
                    children: _subRelation(),
                  )
                ],
              ),
            );
          },
        ));
  }
}
