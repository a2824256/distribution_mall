import 'dart:convert';
import 'dart:io' as H;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mall/api/api.dart';
import 'package:mall/constant/string.dart';
import 'package:mall/entity/goods_detail_entity.dart';
import 'package:mall/event/refresh_event.dart';
import 'package:mall/page/goods/detail_swiper.dart';
import 'package:mall/service/goods_service.dart';
import 'package:mall/service/mine_service.dart';
import 'package:mall/utils/http_util.dart';
import 'package:mall/utils/navigator_util.dart';
import 'package:mall/utils/shared_preferences_util.dart';
import 'package:mall/utils/toast_util.dart';
import 'package:mall/widgets/cached_image.dart';
import 'package:mall/widgets/cart_number.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoodsDetail extends StatefulWidget {
  int goodsId;

  GoodsDetail({Key key, @required this.goodsId}) : super(key: key);

  @override
  _GoodsDetailState createState() => _GoodsDetailState();
}

class _GoodsDetailState extends State<GoodsDetail> {
  int goodsId;
  Map<String, dynamic> result;
  GoodsService _goodsService = GoodsService();
  MineService _mineService = MineService();
  GoodsDetailEntity _goodsDetail;
  var parameters;

  Animation<double> animation;
  String specifications; //规格
  int _specificationIndex = 0;
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);
  int _arrIndex = 0;
  int _number = 1;
  var _goodsDetailFuture;
  var token;
  var _isCollection = false;
  int discount = 0;

  @override
  void initState() {
    super.initState();
    goodsId = widget.goodsId;
    _init_getData();
    var params = {"id": goodsId};
    _goodsDetailFuture =
        _goodsService.getGoodsDetailData(params, (goodsDetail) {
      print("userHasCollect");
      print(goodsDetail.userHasCollect);
      if (goodsDetail.userHasCollect == 1) {
        setState(() {
          _isCollection = true;
        });
      }
      _goodsDetail = goodsDetail;
    });
  }

  _init_getData() async {
    try {
      var h = H.HttpClient();
      String _url =
          Api.DOMAIN + "/index/mall/getGroupBuy?goods_id=" + goodsId.toString();
      var request = await h.getUrl(Uri.parse(_url));
      var response = await request.close();
      var data = await Utf8Decoder().bind(response).join();
      setState(() {
        result = json.decode(data);
        discount = int.parse(result['info']['discount']);
      });
    } catch (e) {
      print(result);
    }
  }

  Future getData() async {
//    try {
    var h = H.HttpClient();
    var request = await h.getUrl(Uri.parse(
        Api.DOMAIN + "/index/mall/getGroupBuy?goods_id=" + goodsId.toString()));
    var response = await request.close();
    var data = await Utf8Decoder().bind(response).join();
    setState(() {
      result = json.decode(data);
      discount = int.parse(result['info']['discount']);
    });
//    } catch (e) {
//      print(result);
//    }
  }

  Widget groupBuyTime() {
    try {
      if (result['info'] != null) {
        return Chip(
            label: Text(
              "活动时间：" +
                  result['info']['add_time'] +
                  ' - ' +
                  result['info']['expire_time'],
              style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenUtil.instance.setSp(20.0)),
            ),
            backgroundColor: Colors.deepOrangeAccent);
      } else {
        return Text('');
      }
//      return FutureBuilder(
//          future: getData(),
//          builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
//            if(result['info']!=null){
//              return Chip(
//                  label: Text(
//                    "活动时间：" + result['info']['add_time'] + ' - ' + result['info']['expire_time'],
//                    style: TextStyle(
//                        color: Colors.white, fontSize: ScreenUtil.instance.setSp(20.0)),
//                  ),
//                  backgroundColor: Colors.deepOrangeAccent);
//            }else{
//              return Text('');
//            }
//          });
    } catch (e) {
      return Text('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text(Strings.GOODS_DETAIL),
          centerTitle: true,
        ),
        body: FutureBuilder(
            future: _goodsDetailFuture,
            builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
              switch (asyncSnapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Container(
                    child: Center(
                      child: SpinKitFoldingCube(
                        size: 40.0,
                        color: Colors.deepOrangeAccent,
                      ),
                    ),
                  );
                default:
                  if (asyncSnapshot.hasError)
                    return Container(
                      child: Center(
                        child: Text(
                          Strings.SERVER_EXCEPTION,
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    );
                  else
                    return _detailView();
              }
            }),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 50.0,
            child: Row(
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.white,
                      child: InkWell(
                        onTap: () => _collection(),
                        child: Icon(
                          Icons.star_border,
                          color: _isCollection
                              ? Colors.deepOrangeAccent
                              : Colors.grey,
                          size: 30.0,
                        ),
                      ),
                    )),
                Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.white,
                      child: InkWell(
                        onTap: () {
                          SharedPreferencesUtils.getToken().then((value) {
                            if (value != null) {
                              //跳转首页,并且第三个页面.
                              NavigatorUtils.goCart(context);
                            } else {
                              NavigatorUtils.goLogin(context);
                            }
                          });
                        },
                        child: Icon(
                          Icons.add_shopping_cart,
                          color: Colors.deepOrangeAccent,
                          size: 30.0,
                        ),
                      ),
                    )),
                Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.deepOrangeAccent,
                      child: InkWell(
                          onTap: () => openBottomSheet(
                              context, _goodsDetail.productList, 1),
                          child: Center(
                            child: Text(
                              Strings.ADD_CART,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 14.0),
                            ),
                          )),
                    )),
                Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.red,
                      child: InkWell(
                          onTap: () => openBottomSheet(
                              context, _goodsDetail.productList, 2),
                          child: Center(
                            child: Text(
                              Strings.BUY,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 14.0),
                            ),
                          )),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  productName(List<ProductList> productList) {
    int length = productList[_arrIndex].specifications.length;
    String txt = '';
    for (int i2 = 0; i2 < length; i2++) {
      txt += productList[_arrIndex].specifications[i2];
      if (i2 != length - 1) txt += '+';
    }
    return txt;
  }

  openBottomSheet(
      BuildContext context, List<ProductList> productList, int showType) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ValueListenableBuilder(
              valueListenable: _counter,
              builder: (BuildContext context, int value, Widget child) {
                return SizedBox(
//            width: double.infinity,
//            height: ScreenUtil.instance.setHeight(999.0),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SingleChildScrollView(
//                    margin: EdgeInsets.all(ScreenUtil.instance.setWidth(20.0)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              CachedImageView(
                                  ScreenUtil.instance.setWidth(120.0),
                                  ScreenUtil.instance.setWidth(120.0),
                                  productList[_arrIndex].url),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    Strings.PRICE +
                                        "：" +
                                        "${productList[_arrIndex].price - discount}",
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontSize:
                                            ScreenUtil.instance.setSp(24.0)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: ScreenUtil.instance
                                            .setHeight(10.0)),
                                  ),
                                  //当前规格
                                  Text(Strings.ALREAD_SELECTED +
                                          "：" +
                                          productName(productList)
//                                _goodsDetail.productList[0]
//                                    .specifications[_specificationIndex]
                                      )
                                ],
                              ),
                              Expanded(
                                  child: Container(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              )),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10.0),
                          child: Text(
                            Strings.SPECIFICATIONS,
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: ScreenUtil.instance.setSp(30.0)),
                          ),
                        ),
                        //TODO 多规格代码

                        Wrap(children: _specificationsWidget(productList)),
//                  Padding(
//                    padding: EdgeInsets.only(
//                        top: ScreenUtil.instance.setHeight(10.0)),
//                  ),
                        Container(
                          margin: EdgeInsets.only(left: 10.0),
                          child: Text(
                            Strings.NUMBER,
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: ScreenUtil.instance.setSp(30.0)),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.only(left: 10.0),
                            height: ScreenUtil.instance.setHeight(80),
                            alignment: Alignment.centerLeft,
                            child: CartNumberView(1, (number) {
                              setState(() {
                                _number = number;
                              });
                              print("${number}");
                            })),
                        Expanded(
                            child: Stack(
                          alignment: Alignment.bottomLeft,
                          children: <Widget>[
                            SizedBox(
                              height: ScreenUtil.instance.setHeight(100.0),
                              width: double.infinity,
                              child: InkWell(
                                  onTap: () =>
                                      showType == 1 ? _addCart() : _buy(),
                                  child: Container(
                                    alignment: Alignment.center,
                                    color: Colors.deepOrangeAccent,
                                    child: Text(
                                      showType == 1
                                          ? Strings.ADD_CART
                                          : Strings.BUY,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                              ScreenUtil.instance.setSp(30.0)),
                                    ),
                                  )),
                            ),
                          ],
                        ))
                      ],
                    ),
                  ),
                );
              });
        });
  }

  List<Widget> _specificationsWidget(List<ProductList> specifications) {
    List<Widget> specificationsWidget = List();
    for (int i = 0; i < specifications.length; i++) {
      if (specifications[i].number <= 0) {
        continue;
      }
      int length = specifications[i].specifications.length;
      String txt = '';
      for (int i2 = 0; i2 < length; i2++) {
        txt += specifications[i].specifications[i2];
        if (i2 != length - 1) txt += '+';
      }
      specificationsWidget.add(Container(
          padding: EdgeInsets.all(ScreenUtil.instance.setWidth(10.0)),
          child: FutureBuilder(
              future: getData(),
              builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                return InkWell(
                  child: ActionChip(
                    onPressed: () {
                      setState(() {
                        _specificationIndex = specifications[i].id;
                        _arrIndex = i;
                        _counter.value += 1;
                      });
                    },
                    label: Text(
                      txt,
                      style: TextStyle(
                          color: specifications[i].id == _specificationIndex
                              ? Colors.white
                              : Colors.black54,
                          fontSize: ScreenUtil.instance.setSp(24.0)),
                    ),
                    backgroundColor: specifications[i].id == _specificationIndex
                        ? Colors.deepOrangeAccent
                        : Colors.grey[200],
                  ),
                );
              })));
    }
    return specificationsWidget;
  }

  _addCart() {
    SharedPreferencesUtils.getToken().then((value) {
      if (value != null) {
        parameters = {
          "goodsId": _goodsDetail.info.id,
          "productId": _specificationIndex,
          "number": _number
        };
        _goodsService.addCart(
          parameters,
          (value) {
            ToastUtil.showToast(Strings.ADD_CART_SUCCESS);
            Navigator.of(context).pop(); //隐藏弹出框
            eventBus.fire(RefreshEvent());
          },
        );
      } else {
        NavigatorUtils.goLogin(context);
      }
    });
  }

  _buy() async {
    if (SharedPreferencesUtils.token != null) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
//      String nickname = sharedPreferences.getString(Strings.NICK_NAME);
      int userid = sharedPreferences.getInt('userid');
      parameters = {
//        "nickname":nickname,
        "userid": userid,
        "goodsId": _goodsDetail.info.id,
        "productId": _specificationIndex,
        "number": _number,
      };
      _goodsService.buy(parameters, (success) {
        print(success);
        NavigatorUtils.goFillInOrder(context, success);
      }, (error) {});
    } else {
      NavigatorUtils.goLogin(context);
    }
  }

  _collection() {
    SharedPreferencesUtils.getToken().then((value) {
      if (value == null) {
        NavigatorUtils.goLogin(context);
      } else {
        token = value;
        _addOrDeleteCollect();
      }
    });
  }

  _addOrDeleteCollect() {
    Options options = Options();
    options.headers["X-Litemall-Token"] = token;
    var parameters = {"type": 0, "valueId": _goodsDetail.info.id};
    _mineService.addOrDeleteCollect(parameters, (onSuccess) {
      if (_isCollection == true) {
        setState(() {
          _isCollection = false;
        });
      } else {
        setState(() {
          _isCollection = true;
        });
      }
      ToastUtil.showToast(onSuccess);
    }, (error) {
      ToastUtil.showToast(error);
    });
  }

  //TODO 商品详情
  Widget _detailView() {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        ListView(
          children: <Widget>[
            DetailSwiperView(_goodsDetail.info.gallery,
                _goodsDetail.info.gallery.length, 430.0),
            Divider(
              height: 2.0,
              color: Colors.grey,
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _goodsDetail.info.name,
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 6.0),
                  ),
                  Text(
                    _goodsDetail.info.brief,
                    style: TextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4.0),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        "专柜价：${_goodsDetail.info.counterPrice}",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0,
                            decoration: TextDecoration.lineThrough),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                      ),
                      Text(
                        "现价：${_goodsDetail.info.retailPrice - discount}",
                        style: TextStyle(
                            color: Colors.deepOrangeAccent, fontSize: 12.0),
                      ),
                    ],
                  ),
                  groupBuyTime()
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 4.0),
            ),
            GoodsEvaluationWidget(
              goodsId: _goodsDetail.info.id,
            ),
            _goodsDetail.attribute == null || _goodsDetail.attribute.length == 0
                ? Divider()
                : Container(
                    child: Column(
                      children: <Widget>[
                        Text(
                          Strings.COMMODITY_PARAMETERS,
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 6.0),
                        ),
                        _attributeView(_goodsDetail),
                      ],
                    ),
                  ),
            Html(data: _goodsDetail.info.detail),
            _goodsDetail.issue == null || _goodsDetail.issue.length == 0
                ? Divider()
                : Container(
                    child: Column(
                      children: <Widget>[
//                        Text(
//                          Strings.COMMON_PROBLEM,
//                          style: TextStyle(
//                              color: Colors.black54,
//                              fontSize: 20.0,
//                              fontWeight: FontWeight.bold),
//                        ),
//                        Padding(
//                          padding: EdgeInsets.only(top: 6.0),
//                        ),
//                        _issueView(_goodsDetail),
                      ],
                    ),
                  ),
          ],
        ),
      ],
    );
  }

  //商品属性Widget
  Widget _attributeView(GoodsDetailEntity goodsDetail) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: goodsDetail.attribute.length,
        itemBuilder: (BuildContext context, int index) {
          return _attributeItemView(goodsDetail.attribute[index]);
        });
  }

  //页面商品参数
  Widget _attributeItemView(Attribute attribute) {
    return Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(10.0)),
        padding: EdgeInsets.all(6.0),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Text(
                attribute.attribute,
                style: TextStyle(color: Colors.black54, fontSize: 14.0),
              ),
            ),
            Expanded(
                flex: 4,
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    attribute.value,
                    style: TextStyle(color: Colors.grey, fontSize: 14.0),
                  ),
                )),
          ],
        ));
//    return Text('test');
  }

//常见问题
//  Widget _issueView(GoodsDetailEntity goodsDetail) {
//    return ListView.builder(
//        physics: NeverScrollableScrollPhysics(),
//        shrinkWrap: true,
//        itemCount: goodsDetail.issue.length,
//        itemBuilder: (BuildContext context, int index) {
//          return _issueItemView(goodsDetail.issue[index]);
//        });
//  }

//  Widget _issueItemView(Issue issue) {
//    return Container(
//        margin: EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
//        padding: EdgeInsets.all(6.0),
//        child: Column(
//          crossAxisAlignment: CrossAxisAlignment.start,
//          children: <Widget>[
//            Text(
//              issue.question,
//              style: TextStyle(color: Colors.black54, fontSize: 14.0),
//            ),
//            Padding(
//              padding: EdgeInsets.only(top: 10.0),
//            ),
//            Container(
//                alignment: Alignment.centerLeft,
//                child: Text(
//                  issue.answer,
//                  style: TextStyle(color: Colors.grey, fontSize: 14.0),
//                )),
//          ],
//        ));
//  }
}

//class AnimatedImage extends AnimatedWidget {
//  AnimatedImage({Key key, Animation<double> animation})
//      : super(key: key, listenable: animation);
//
//  Widget build(BuildContext context) {
//    final Animation<double> animation = listenable;
//    return new Center(
//      child: Image.asset("images/splash.png",
//          width: animation.value, height: animation.value),
//    );
//  }
//}

class GoodsEvaluationWidget extends StatefulWidget {
  final int goodsId;

  const GoodsEvaluationWidget({Key key, @required this.goodsId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GoodsEvaluationWidgetState();
  }
}

class _GoodsEvaluationWidgetState extends State<GoodsEvaluationWidget> {
  Map _comments = {};

  String _userName = "";

  String _content = "";

  @override
  void initState() {
    _getComments();
    super.initState();
  }

  void _getComments() async {
    print('goodsId');
    print(widget.goodsId);
    var response = await HttpUtil.instance.get(Api.DOMAIN +
        "/index/index/getComments/?page=0&limit=1&goodsId=${widget.goodsId}");
    if (response['errno'] == 0) {
      _comments = response['data'][0];
      setState(() {
        _userName = _comments["nickname"];
        _content = _comments["content"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_comments.isEmpty) {
      return Container();
    }
    final font = TextStyle(color: Colors.grey, fontSize: 14);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: Text(
                "商品评价",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              )),
              GestureDetector(
                onTap: () {
                  //todo 跳转评价列表
                  NavigatorUtils.goGoodsComments(context, widget.goodsId);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Text(
                    "查看更多",
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 16),
            child: Text(
              "用户: ${_userName}",
              style: font,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 16, bottom: 16),
            child: Text(
              "评价: ${_content}",
              style: font,
            ),
          ),
        ],
      ),
    );
  }
}
