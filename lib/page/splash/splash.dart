import 'dart:async';
import 'dart:convert';
import 'dart:io' as H;

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:mall/api/api.dart';
import 'package:mall/utils/fluwx_utls.dart';
import 'package:mall/utils/navigator_util.dart';

EventBus eventBus = new EventBus();

class MyEvent {
  String text;

  MyEvent(this.text);
}

class SplashView extends StatefulWidget {
  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  Timer _timer;
  Map<String, dynamic> result;
  String url;
  int aid = 264;
  int time = 0;
  int count = 0;
  var period = const Duration(seconds: 1);
  GlobalKey<TextWidgetState> textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initFluwx();
  }

  Future getData() async {
    if (time == 0) {
      var h = H.HttpClient();
      var request =
          await h.getUrl(Uri.parse(Api.DOMAIN + "/index/mall/startUpInfo"));
      var response = await request.close();
      var data = await Utf8Decoder().bind(response).join();
      result = json.decode(data);
      url = result['data']['pic']['key_value'];
      aid = int.parse(result['data']['aid']['key_value']);
      time = int.parse(result['data']['time']['key_value']);
    }
  }

  @override
  void dispose() {
    super.dispose();
    Navigator.pop(context);
    eventBus.destroy();
  }

  //TODO 启动页面
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FutureBuilder(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
          switch (asyncSnapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Scaffold(
                body: Container(
                  color: Colors.deepOrangeAccent,
                  child: Text(''),
                ),
              );
            default:
              if (asyncSnapshot.hasError)
                return Container(
                  child: Center(
                    child: Text(
                      "",
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                );
              else
                try {
                  _timer = Timer.periodic(period, (timer) {
                    //到时回调
                    eventBus.fire(MyEvent(time.toString()));
                    time--;
                    if (time <= 0) {
                      //取消定时器，避免无限回调
                      eventBus.destroy();
                      timer.cancel();
                      timer = null;
                      Navigator.pop(context);
                      NavigatorUtils.goMallMainPage(context);
                    }
                  });
                } catch (e) {
                  eventBus.destroy();
                }
              return Scaffold(
                body: Container(
                  color: Colors.deepOrangeAccent,
                  child: InkWell(
                      onTap: () {
//                        Navigator.push( context,
//                            MaterialPageRoute(builder: (context) {
//                              return PayView();
//                            }));
                        eventBus.destroy();
                        Navigator.pop(context);
                        NavigatorUtils.goMallMainPage(context);
                        NavigatorUtils.goProjectSelectionDetail(
                            context, aid, false);
                        _timer.cancel();
                      },
                      child: Stack(
                        children: <Widget>[
                          Image.network(
                            url,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.fill,
                          ),
                          Positioned(
                            top: 30,
                            left: size.width - 100,
                            child: FlatButton(
                                onPressed: () {
                                  _timer.cancel();
                                  eventBus.destroy();
                                  Navigator.pop(context);
                                  NavigatorUtils.goMallMainPage(context);
                                },
                                child: TextWidget()),
                          )
                        ],
                      )),
                ),
              );
          }
        });
  }
}

class TextWidget extends StatefulWidget {
  int count;

  TextWidget({Key key, this.count}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TextWidgetState();
  }
}

class TextWidgetState extends State<TextWidget> {
  String str_sub = '';

  void initState() {
    super.initState();
    eventBus.on<MyEvent>().listen((MyEvent data) {
      if (str_sub != data.text) {
        setState(() {
          str_sub = data.text;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "${str_sub} 跳过",
        style: TextStyle(fontSize: 15, color: Colors.deepOrange),
      ),
    );
  }
}
