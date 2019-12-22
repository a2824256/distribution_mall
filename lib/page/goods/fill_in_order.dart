import 'dart:ui' as prefix0;
import 'package:mall/utils/http_util.dart';
import 'package:flutter/material.dart';
import 'package:mall/constant/string.dart';
import 'package:mall/entity/fill_in_order_entity.dart';
import 'package:mall/service/goods_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mall/widgets/item_text.dart';
import 'package:dio/dio.dart';
import 'package:mall/utils/shared_preferences_util.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mall/utils/navigator_util.dart';
import 'package:mall/utils/fluro_convert_utils.dart';
import 'package:mall/utils/toast_util.dart';
import 'package:mall/widgets/cached_image.dart';
import 'dart:io' as H;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:mall/api/api.dart';

class FillInOrderView extends StatefulWidget {
  var cartId;

  FillInOrderView(this.cartId);

  @override
  _FillInOrderViewState createState() => _FillInOrderViewState();
}

class _FillInOrderViewState extends State<FillInOrderView> {
  FillInOrderEntity _fillInOrderEntity;
  GoodsService _goodsService = GoodsService();
  TextEditingController _controller = TextEditingController();
  var token;
  Future future;
  Options options = Options();
  var order_id;
  String order_sn;
  var _token;
  int address_id = 0;
  double carriage = 0;

  @override
  void initState() {
    super.initState();
    SharedPreferencesUtils.getToken().then((onValue) {
      token = onValue;
      _getFillInOrder();
//      _getCarriage(address_id);
    });
    _initFluwx();
    fluwx.responseFromPayment.listen((data) {
      Navigator.popAndPushNamed(
          context, '/mineOrderDetail' + "?orderId=$order_id&token=$token");
      print("----------调用微信返回----------------");
      print("data=$data|||||||errCode=${data.errCode},"
          "androidOpenId=${data.androidOpenId},"
          "iosDes=${data.iOSDescription},"
          "androidPrepayId=${data.androidPrepayId},"
          "extData=${data.extData},"
          "androidTransaction=${data.androidTransaction}");
      print("------------------------------------");
    });
  }

  _initFluwx() async {
    await fluwx.registerWxApi(appId: "wxe6ff833092d5dd45");
  }

  _pay(order_sn) async {
    String _url = Api.DOMAIN + "/index/index/pre_order/?order_sn=" + order_sn;
    var h = H.HttpClient();
    h.badCertificateCallback = (cert, String host, int port) {
      return true;
    };
    var request = await h.getUrl(Uri.parse(_url));
    var response = await request.close();
    var data = await Utf8Decoder().bind(response).join();
    Map<String, dynamic> result = json.decode(data);
    print("========返回的参数==========");
    print("map=$result");
    print("===========================");
    //appid:wxe6ff833092d5dd45
    //商户号:1563782161
    fluwx
        .pay(
      appId: result['appid'],
      partnerId: result['mch_id'],
      prepayId: result['prepay_id'],
      packageValue: 'Sign=WXPay',
      nonceStr: result['nonce_str'],
      timeStamp: int.parse(result['timestamp']),
      sign: result['re_sign'],
    )
        .then((data) {
      print('!!!!!!!!!!!!!!!');
      print("---》$data");
    });
  }

//
//  _getFillInOrder_b() {
//    future = _getFillInOrder_future((success) {
//      setState(() {
//        _fillInOrderEntity = success;
//      });
//    }, (error) {});
//  }

  _getFillInOrder() async {
    print('fill_in');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int userid = sharedPreferences.getInt('userid');
    var parameters;
    parameters = {
      "userid": userid,
      "cartId": widget.cartId == 0 ? 0 : widget.cartId,
    };
    future = _goodsService.cartCheckOut((success) {
      setState(() {
        _fillInOrderEntity = success;
        carriage = _fillInOrderEntity.freightPrice;
      });
    }, (error) {}, parameters);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
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
                      style:
                          TextStyle(fontSize: ScreenUtil.instance.setSp(26.0)),
                    ),
                  ),
                );
              else
                return _contentWidget();
          }
        });
  }

  _contentWidget() {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.FILL_IN_ORDER),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            children: <Widget>[
              _addressWidget(),
              Divider(
                height: ScreenUtil.instance.setHeight(1.0),
                color: Colors.grey[350],
              ),
//            _couponWidget(),
              Divider(
                height: ScreenUtil.instance.setHeight(1.0),
                color: Colors.grey[350],
              ),
              _remarkWidget(),
              Divider(
                height: ScreenUtil.instance.setHeight(1.0),
                color: Colors.grey[350],
              ),
              ItemTextView('商品合计', "¥${_fillInOrderEntity.goodsTotalPrice}"),
              Divider(
                height: ScreenUtil.instance.setHeight(1.0),
                color: Colors.grey,
              ),
              ItemTextView('积分抵消金额', "-¥${_fillInOrderEntity.integralDixiao}"),
              Divider(
                height: ScreenUtil.instance.setHeight(1.0),
                color: Colors.grey[350],
              ),
              ItemTextView(Strings.FREIGHT, "¥${carriage.toString()}"),
              Divider(
                height: ScreenUtil.instance.setHeight(1.0),
                color: Colors.grey[350],
              ),
//              ItemTextView(
//                  Strings.GOODS_TOTAL, "¥${_fillInOrderEntity.couponPrice}"),
              Divider(
                height: ScreenUtil.instance.setHeight(1.0),
                color: Colors.grey[350],
              ),
//            ListView.builder(itemBuilder: (BuildContext context, int index) {
//              return _goodsItem(_fillInOrderEntity.checkedGoodsList[index]);
//            })
              Column(
                children: _goodsItems(_fillInOrderEntity.checkedGoodsList),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          margin: EdgeInsets.only(left: ScreenUtil.instance.setWidth(20.0)),
          height: ScreenUtil.instance.setHeight(100.0),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Text(
                      "实付：¥${(_fillInOrderEntity.orderTotalPrice + carriage).toString()}")),
              Expanded(
                  child: Text(
                "我的积分：${_fillInOrderEntity.integral}",
                style: TextStyle(color: Colors.red),
              )),
              InkWell(
                onTap: () => _submitOrder(),
                child: Container(
                  alignment: Alignment.center,
                  width: ScreenUtil.instance.setWidth(200.0),
                  height: double.infinity,
                  color: Colors.deepOrangeAccent,
                  child: Text(
                    Strings.PAY,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil.instance.setSp(28.0)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _goodsItems(List<CheckedGoodsList> goods) {
    List<Widget> widgets = List();
    for (int i = 0; i < goods.length; i++) {
      widgets.add(_goodsItem(goods[i]));
      widgets.add(Divider(
        height: ScreenUtil.instance.setHeight(1.0),
        color: Colors.grey[350],
      ));
    }
    return widgets;
  }

  Widget _goodsItem(CheckedGoodsList checkedGoods) {
    return Container(
//      padding: EdgeInsets.only(
//          left: ScreenUtil.instance.setWidth(20.0),
//          right: ScreenUtil.instance.setWidth(20.0)),
      height: ScreenUtil.instance.setHeight(180.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CachedImageView(ScreenUtil.instance.setWidth(140),
              ScreenUtil.instance.setWidth(140), checkedGoods.picUrl),
          Padding(
            padding: EdgeInsets.only(left: ScreenUtil.instance.setWidth(10.0)),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  checkedGoods.goodsName,
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: ScreenUtil.instance.setSp(26.0)),
                ),
                Padding(
                    padding: EdgeInsets.only(
                        top: ScreenUtil.instance.setHeight(6.0))),
                Text(
                  checkedGoods.specifications[0],
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: ScreenUtil.instance.setSp(22.0)),
                ),
                Padding(
                    padding: EdgeInsets.only(
                        top: ScreenUtil.instance.setHeight(20.0))),
                Text(
                  "¥${checkedGoods.price}",
                  style: TextStyle(
                      color: Colors.deepOrangeAccent,
                      fontSize: ScreenUtil.instance.setSp(26.0)),
                )
              ],
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            child: Text("X${checkedGoods.number}"),
          )
        ],
      ),
    );
  }

  Widget _remarkWidget() {
    return Container(
      height: ScreenUtil.instance.setHeight(80),
      width: double.infinity,
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            Strings.REMARK,
            style: TextStyle(
                color: Colors.black54,
                fontSize: ScreenUtil.instance.setSp(26.0)),
          ),
          Expanded(
              child: Container(
            margin: EdgeInsets.only(left: ScreenUtil.instance.setWidth(10.0)),
            height: ScreenUtil.instance.setHeight(80.0),
            alignment: Alignment.centerLeft,
            child: TextField(
              maxLines: 1,
              decoration: InputDecoration(
                hintText: Strings.REMARK,
                //border: OutlineInputBorder(borderSide: BorderSide.none),
                hintStyle: TextStyle(
                    color: Colors.grey[350],
                    fontSize: ScreenUtil.instance.setSp(26.0)),
                hasFloatingPlaceholder: false,
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.transparent,
                        width: ScreenUtil.instance.setHeight(1.0))),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.transparent,
                        width: ScreenUtil.instance.setHeight(1.0))),
              ),
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: ScreenUtil.instance.setSp(26.0)),
              controller: _controller,
            ),
          ))
        ],
      ),
    );
  }

//  Widget _couponWidget() {
//    return Container(
//      width: double.infinity,
//      height: ScreenUtil.instance.setHeight(100),
//      margin: EdgeInsets.only(top: ScreenUtil.instance.setHeight(10.0)),
//      padding: EdgeInsets.only(
//          left: ScreenUtil.instance.setWidth(20.0),
//          right: ScreenUtil.instance.setWidth(20.0)),
//      child: Row(
//        children: <Widget>[
//          _fillInOrderEntity.availableCouponLength == 0
//              ? Text(
//                  Strings.NOT_AVAILABLE_COUPON,
//                  style: TextStyle(
//                      color: Colors.black54,
//                      fontSize: ScreenUtil.instance.setSp(26.0)),
//                )
//              : Text(
//                  Strings.COUPON,
//                  style: TextStyle(
//                      color: Colors.black54,
//                      fontSize: ScreenUtil.instance.setSp(26.0)),
//                ),
//          Expanded(
//              child: Container(
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.end,
//              children: <Widget>[
//                Text(
//                  "${_fillInOrderEntity.couponPrice}元",
//                  style: TextStyle(
//                      color: Colors.grey,
//                      fontSize: ScreenUtil.instance.setSp(24.0)),
//                ),
//                Padding(
//                  padding:
//                      EdgeInsets.only(left: ScreenUtil.instance.setWidth(10.0)),
//                ),
//                Icon(
//                  Icons.arrow_forward_ios,
//                  color: Colors.grey,
//                )
//              ],
//            ),
//          ))
//        ],
//      ),
//    );
//  }

  _getCarriage(address_id) async {
//    try {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String nickname = sharedPreferences.getString(Strings.NICK_NAME);
    var h = H.HttpClient();
    String _url = Api.DOMAIN +
        "/index/index/addressPrice/?address_id=" +
        address_id.toString() +
        "&nickname=" +
        nickname;
    var request = await h.getUrl(Uri.parse(_url));
    print(_url);
    var response = await request.close();
    var data = await Utf8Decoder().bind(response).join();
    var result = json.decode(data);
    print('carriageprice');
    print(result['data']['carriage']);
    double carriageprice = double.parse(result['data']['carriage']);
    setState(() {
      carriage = carriageprice;
    });
    print('运费');
    print(carriage);
//    } catch (e) {
//      print('error!!!!!!!!!!');
//      print(e.toString());
//    }
  }

  Widget _addressWidget() {
    return Container(
      height: ScreenUtil.instance.setHeight(120.0),
      child: _fillInOrderEntity.checkedAddress.id != 0
          ? InkWell(
              onTap: () async {
                Map address = FluroConvertUtil.stringToMap(
                    await NavigatorUtils.goAddress(context));

                var checkedAddress = CheckedAddress.fromJson(address);
                address_id = checkedAddress.id;
                _getCarriage(address_id);
                setState(() {
                  _fillInOrderEntity.checkedAddress = checkedAddress;
                });
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _fillInOrderEntity.checkedAddress.name,
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: ScreenUtil.instance.setSp(28.0)),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: ScreenUtil.instance.setHeight(20.0)),
                          ),
                          Text(
                            _fillInOrderEntity.checkedAddress.tel,
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: ScreenUtil.instance.setSp(26.0)),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: ScreenUtil.instance.setHeight(10.0)),
                      ),
                      Text(
                        _fillInOrderEntity.checkedAddress.province +
                            _fillInOrderEntity.checkedAddress.city +
                            _fillInOrderEntity.checkedAddress.county +
                            _fillInOrderEntity.checkedAddress.addressDetail,
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: ScreenUtil.instance.setSp(26.0)),
                      ),
                    ],
                  ),
                  Expanded(
                      child: Container(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                    ),
                  ))
                ],
              ),
            )
          : InkWell(
              onTap: () async {
                Map address = FluroConvertUtil.stringToMap(
                    await NavigatorUtils.goAddress(context));
                var checkedAddress = CheckedAddress.fromJson(address);
                address_id = checkedAddress.id;
                _getCarriage(address_id);
                setState(() {
                  _fillInOrderEntity.checkedAddress = checkedAddress;
                });
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    Strings.PLEASE_SELECT_ADDRESS,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: ScreenUtil.instance.setSp(30.0)),
                  ),
                  Expanded(
                      child: Container(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                    ),
                  ))
                ],
              ),
            ),
    );
  }

  Future submitOrder(
    Options options,
    Map<String, dynamic> parameters,
    OnSuccess onSuccess,
    OnFail onFail,
  ) async {
    try {
      String _url = Api.DOMAIN +
          '/index/index/settleMent?userid=' +
          parameters['userid'].toString() +
          '&address_id=' +
          parameters['address_id'].toString();
      var response = await HttpUtil.instance
          .post(_url, parameters: parameters, options: options);
      if (response['errno'] == 0) {
        print(_url);
        print(response);
        order_id = response['data']['orderId'];
        onSuccess(Strings.SUCCESS);
      } else {
        onFail(response['errmsg']);
      }
    } catch (e) {
      print(e);
      onFail(Strings.SERVER_EXCEPTION);
    }
  }

  Future getOrder(
    Options options,
    Map<String, dynamic> parameters,
    OnSuccess onSuccess,
    OnFail onFail,
  ) async {
    try {
      var response = await HttpUtil.instance.post(
          Api.DOMAIN + '/index/index/getOrderSN',
          parameters: parameters,
          options: options);
      if (response['errno'] == 0) {
        order_sn = response['order_sn'];
        onSuccess(Strings.SUCCESS);
      } else {
        onFail(response['errmsg']);
      }
    } catch (e) {
      print(e);
      onFail(Strings.SERVER_EXCEPTION);
    }
  }

  _submitOrder() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int userid = sharedPreferences.getInt('userid');
    if (_fillInOrderEntity.checkedAddress.id == 0) {
      ToastUtil.showToast(Strings.PLEASE_SELECT_ADDRESS);
      return;
    }
    var parameters = {
      "userid": userid,
      "address_id": _fillInOrderEntity.checkedAddress.id,
    };
    submitOrder(options, parameters, (success) {
      print(success);
      var parameters2 = {
        "order_id": order_id,
      };
      getOrder(options, parameters2, (success) {
        _pay(order_sn);
        // NavigatorUtils.submitOrderSuccessPop(context);
      }, (error) {
        ToastUtil.showToast(error);
      });
      // NavigatorUtils.submitOrderSuccessPop(context);
    }, (error) {
      ToastUtil.showToast(error);
    });
  }
}
