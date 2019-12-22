import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mall/api/api.dart';
import 'package:mall/utils/http_util.dart';
import 'package:mall/widgets/divider_line.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ItemText2.dart';
import 'relation.dart';
import 'takeCash.dart';

class AboutUsView extends StatefulWidget {
  @override
  _AboutUsViewState createState() => _AboutUsViewState();
}

class _AboutUsViewState extends State<AboutUsView> {
  @override
  void initState() {
    super.initState();
    _getData();
  }

  Map<String, dynamic> result;

  @override
  void deactivate() {
    var bool = ModalRoute.of(context).isCurrent;
    if (bool) {
      _getData();
    }
  }

  void _getData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int userid = await sharedPreferences.getInt('userid');
    String _url =
        Api.DOMAIN + '/index/mall/getCashoutList_app?userid=${userid}';
    print(_url);
    var response = await HttpUtil.instance.post(_url, parameters: {});
    print(response);
    setState(() {
      result = response;
    });
  }

  List<Widget> _subRelation() {
//    try {
    List<Widget> list = List();
    if (result == null) {
      list.add(Text(''));
      return list;
    }
    for (int i = 0; i < result['data']['record'].length; i++) {
      var cash = result['data']['record'][i]['cash'];
      if (result['data']['record'][i]['status'] == 1) {
        list.add(ItemText2View('+ ￥' + cash.toString(),
            result['data']['record'][i]['add_time'], '已完成'));
      } else {
        list.add(ItemText2View('+ ￥' + cash.toString(),
            result['data']['record'][i]['add_time'], '处理中'));
      }
      list.add(DividerLineView());
    }
    return list;
//    } catch (e) {
//      return [DividerLineView()];
//    }
  }

  Widget _cashout() {
    if (result == null) {
      return Container(
        padding: EdgeInsets.only(top: 20.0, bottom: 30.0),
        child: Text('￥0', style: TextStyle(fontSize: 30.0, color: Colors.red)),
      );
    } else {
      double cashout = double.parse(result['cashout']) ?? 0.00;
      if (cashout > 0) {
        return Container(
          padding: EdgeInsets.only(top: 20.0, bottom: 30.0),
          child: Text('￥' + cashout.toString(),
              style: TextStyle(fontSize: 30.0, color: Colors.red)),
        );
      } else {
        return Container(
          padding: EdgeInsets.only(top: 20.0, bottom: 30.0),
          child:
              Text('￥0', style: TextStyle(fontSize: 30.0, color: Colors.red)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('分销关系'),
          centerTitle: true,
        ),
        body: Container(
          margin: EdgeInsets.all(ScreenUtil.instance.setWidth(20.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Text('可提现佣金',
                            style: TextStyle(
                              fontSize: 20.0,
                            )),
                        _cashout()
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                          child: Column(
                            children: <Widget>[
//                                        ActionChip(
//                                          onPressed: () {
//                                            Fluttertoast.showToast(
//                                                msg: "没有可提现金额",
//                                                toastLength: Toast.LENGTH_SHORT,
//                                                gravity: ToastGravity.CENTER,
//                                                timeInSecForIos: 1,
//                                                backgroundColor:
//                                                Colors.deepOrangeAccent,
//                                                textColor: Colors.white,
//                                                fontSize: ScreenUtil.instance
//                                                    .setSp(28.0));
//                                          },
//                                          label: Text(
//                                            '提现',
//                                            style: TextStyle(
//                                                height: 1.2,
//                                                color: Colors.white,
//                                                fontSize: ScreenUtil.instance
//                                                    .setSp(24.0)),
//                                          ),
//                                          backgroundColor: Colors.deepOrangeAccent,
//                                        ),
                              ActionChip(
                                onPressed: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return RelationView();
                                  }));
                                },
                                label: Text(
                                  '查看分销关系',
                                  style: TextStyle(
                                      height: 1.2,
                                      color: Colors.white,
                                      fontSize:
                                          ScreenUtil.instance.setSp(24.0)),
                                ),
                                backgroundColor: Colors.deepOrangeAccent,
                              ),
                              ActionChip(
                                onPressed: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return takeCashView();
                                  }));
                                },
                                label: Text(
                                  '    提现佣金    ',
                                  style: TextStyle(
                                      height: 1.2,
                                      color: Colors.white,
                                      fontSize:
                                          ScreenUtil.instance.setSp(24.0)),
                                ),
                                backgroundColor: Colors.deepOrangeAccent,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )),
              DividerLineView(),
              Container(
                padding: EdgeInsets.only(top: 20.0),
                child: Text('提现记录'),
              ),
              Padding(
                  padding: EdgeInsets.all(ScreenUtil.instance.setHeight(10.0))),
              DividerLineView(),
              Column(
                children: _subRelation(),
              )
            ],
          ),
        ));
  }
}
