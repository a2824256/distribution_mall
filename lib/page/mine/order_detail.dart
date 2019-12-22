import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:mall/api/api.dart';
import 'package:mall/constant/string.dart';
import 'package:mall/entity/order_detail_entity.dart';
import 'package:mall/service/mine_service.dart';
import 'package:mall/utils/http_util.dart';
import 'package:mall/utils/navigator_util.dart';
import 'package:mall/utils/toast_util.dart';
import 'package:mall/widgets/divider_line.dart';
import 'package:mall/widgets/empty_view.dart';
import 'package:mall/widgets/item_text.dart';

class OrderDetail extends StatefulWidget {
  var orderId;
  var token;

  OrderDetail(this.orderId, this.token);

  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  MineService _mineService = MineService();
  OrderDetailEntity _orderDetailEntity;
  Future _orderDetailFuture;
  var action;
  var parameters;
  String express;
  String expressCom;
  bool refresh = false;
  List comments;
  String refundExpress;

  @override
  void initState() {
    super.initState();

    parameters = {"orderId": widget.orderId};
    _queryOrderDetail();
    fluwx.responseFromPayment.listen((data) {
      if (data.errCode == 0) {
        setState(() {
          _queryOrderDetail();
        });
      }
    });
  }

  @override
  void deactivate() {
    var bool = ModalRoute.of(context).isCurrent;

    if (bool) {
      _queryOrderDetail();
      _getExpress();
    }
  }

  Future _getExpress() async {
    String _url = Api.DOMAIN +
        "/index/index/getOrderInfo?order_sn=${_orderDetailEntity.orderInfo.orderSn}";
    var response = await HttpUtil.instance.get(_url);
//    if(response['data']['ship_channel']!=null && response['data']['ship_sn']!=null){
    refundExpress = response['data']['refund_ship_sn'];
    setState(() {
      if (response['data']['comment'] != null) {
        comments = response['data']['comment'];
      }
      expressCom = response['data']['ship_channel'];
      express = response['data']['ship_sn'];
    });
//    }
  }

  _queryOrderDetail() {
    _orderDetailFuture = _mineService.queryOrderDetail(parameters, (success) {
      _orderDetailEntity = success;
    }, (error) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.MINE_ORDER_DETAIL),
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: _orderDetailFuture,
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
                if (asyncSnapshot.hasError) {
                  return Container(
                    height: double.infinity,
                    child: EmptyView(),
                  );
                } else {
                  return _contentView();
                }
            }
          }),
    );
  }

  Widget _contentView() {
    bool hidden = false;
    if (refundExpress != null) {
      hidden = true;
    }
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(ScreenUtil.instance.setWidth(20.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ItemTextView(
                Strings.MINE_ORDER_SN, _orderDetailEntity.orderInfo.orderSn),
            DividerLineView(),
            ItemTextView(
                Strings.MINE_ORDER_TIME, _orderDetailEntity.orderInfo.addTime),
            DividerLineView(),
            Container(
                margin:
                    EdgeInsets.only(left: ScreenUtil.instance.setWidth(20.0)),
                height: ScreenUtil.instance.setHeight(80.0),
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      Strings.ORDER_INFORMATION,
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: ScreenUtil.instance.setSp(26)),
                    ),
                    Expanded(
                        child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _orderDetailEntity.orderInfo.orderStatusText,
                        style: TextStyle(
                            color: Colors.deepOrangeAccent,
                            fontSize: ScreenUtil.instance.setSp(26.0)),
                      ),
                    ))
                  ],
                )),
            DividerLineView(),
            ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _orderDetailEntity.orderGoods.length,
                itemBuilder: (BuildContext context, int index) {
                  bool inArray = false;
                  if (comments != null) {
                    inArray = comments.contains(
                        _orderDetailEntity.orderGoods[index].productId);
                  }
                  return _goodItemView(
                      _orderDetailEntity.orderGoods[index],
                      (_orderDetailEntity.orderInfo.orderStatusText == "已收货" ||
                              _orderDetailEntity.orderInfo.orderStatusText ==
                                  "已收货(系统)") &&
                          !inArray);
                }),
            DividerLineView(),
            Container(
              margin: EdgeInsets.only(
                  left: ScreenUtil.instance.setWidth(20.0),
                  top: ScreenUtil.instance.setHeight(20.0),
                  bottom: ScreenUtil.instance.setHeight(20.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        _orderDetailEntity.orderInfo.consignee,
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: ScreenUtil.instance.setSp(26.0)),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: ScreenUtil.instance.setWidth(20.0)),
                      ),
                      Text(
                        _orderDetailEntity.orderInfo.mobile,
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: ScreenUtil.instance.setSp(26.0)),
                      ),
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          top: ScreenUtil.instance.setHeight(20.0))),
                  Text(
                    _orderDetailEntity.orderInfo.address,
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: ScreenUtil.instance.setSp(26.0)),
                    softWrap: true,
                  ),
                ],
              ),
            ),
            DividerLineView(),
            ItemTextView(Strings.MINE_ORDER_DETAIL_TOTAL,
                Strings.DOLLAR + "${_orderDetailEntity.orderInfo.goodsPrice}"),
            DividerLineView(),
            ItemTextView(
                Strings.FREIGHT,
                Strings.DOLLAR +
                    "${_orderDetailEntity.orderInfo.freightPrice}"),
            DividerLineView(),
            ItemTextView('优惠',
                Strings.DOLLAR + "${_orderDetailEntity.orderInfo.couponPrice}"),
            DividerLineView(),
            ItemTextView(Strings.MINE_ORDER_DETAIL_PAYMENTS,
                Strings.DOLLAR + "${_orderDetailEntity.orderInfo.actualPrice}"),
            DividerLineView(),
            FutureBuilder(
                future: _getExpress(),
                builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                  return Container(
                    child: Column(children: <Widget>[
                      ItemTextView('物流', "${expressCom ?? "暂无"}"),
                      DividerLineView(),
                      ItemTextView('物流单号', "${express ?? "暂无"}"),
                      DividerLineView(),
                    ]),
                  );
                }),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: _OrderButton(
                  hidden: hidden,
                  orderStatus: _orderDetailEntity.orderInfo.orderStatusText,
                  onTap: (text) {
                    switch (text) {
                      case "继续支付":
                        continuePay();
                        break;
                      case "确认收货":
                        confirmReceipt();
                        break;
                      case "申请退款":
                        NavigatorUtils.goApplyRefund(
                            context, _orderDetailEntity.orderInfo.orderSn);
                        break;
                      case "删除订单":
                        _deleteOrder();
                        break;
                      case "取消订单":
                        showMyMaterialDialog(context);
                        break;
                      case "填写退款快递信息":
                        NavigatorUtils.goApplyExpress(
                            context, _orderDetailEntity.orderInfo.orderSn);
                        break;
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }

  showMyMaterialDialog(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            title: new Text("提示"),
            content: new Text("是否取消该订单？"),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  cancelOrder();
                },
                child: new Text("确认"),
              ),
              new FlatButton(
                onPressed: () {
                  Navigator.pop(context, "1");
                },
                child: new Text("取消"),
              ),
            ],
          );
        });
  }

  cancelOrder() async {
    var result = await HttpUtil.instance
        .get(Api.DOMAIN + "/index/index/cancelOrder", parameters: {
      "orderid": widget.orderId,
    });
    print(result);
    if (result['errno'] == 0) {
      ToastUtil.showToast('取消成功，返还积分');
      Navigator.pop(context, "1");
      super.setState(() {
        _queryOrderDetail();
      });
    } else {
      ToastUtil.showToast(result['errmsg']);
    }
  }

  Widget _goodItemView(OrderGoods good, bool showEvaluation) {
    Widget specificationsRow = Text(
      good.specifications[0],
      style: TextStyle(
          color: Colors.grey, fontSize: ScreenUtil.instance.setSp(26.0)),
    );
    if (showEvaluation) {
      //去评价
      specificationsRow = Row(
        children: <Widget>[
          Expanded(
            child: Text(
              good.specifications[0],
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: ScreenUtil.instance.setSp(26.0)),
            ),
          ),
          SizedBox(
            width: 4,
          ),
          OutlineButton(
            onPressed: () {
              //goto 去评价界面
//              Navigator.pop(context);
              NavigatorUtils.goGoodsEvaluation(
                  context,
                  good.goodsName,
                  good.goodsId,
                  _orderDetailEntity.orderInfo.orderSn,
                  good.productId);
            },
            child: Text(
              "去评价",
              style: TextStyle(fontSize: 12, color: Colors.deepOrange),
            ),
          ),
        ],
      );
    }
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.network(
            good.picUrl,
            width: ScreenUtil.instance.setWidth(160.0),
            height: ScreenUtil.instance.setHeight(160.0),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                  left: ScreenUtil.instance.setWidth(20.0),
                  top: ScreenUtil.instance.setHeight(20.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    good.goodsName,
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: ScreenUtil.instance.setSp(26.0)),
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          top: ScreenUtil.instance.setHeight(10.0))),
                  specificationsRow,
                  Padding(
                      padding: EdgeInsets.only(
                          top: ScreenUtil.instance.setHeight(10.0))),
//                Wrap(
//                  alignment: WrapAlignment.center,
//                  children: <Widget>[
//                    Container(
//                      padding:
//                          EdgeInsets.all(ScreenUtil.instance.setWidth(6.0)),
//                      alignment: Alignment.center,
//                      decoration: BoxDecoration(
//                        border: new Border.all(
//                            color: Colors.deepOrangeAccent,
//                            width: ScreenUtil.instance.setWidth(1.0)), // 边色与边宽度
//                        color: Colors.deepOrangeAccent, // 底色
//                        borderRadius: new BorderRadius.circular(
//                            (ScreenUtil.instance.setWidth(20.0))), // 圆角度
//                      ),
//                      child: Text(
//                        Strings.MINE_ORDER_TAG_ONE,
//                        style: TextStyle(
//                            color: Colors.white,
//                            fontSize: ScreenUtil.instance.setSp(20.0)),
//                      ),
//                    ),
//                    Container(
//                      margin: EdgeInsets.only(
//                          left: ScreenUtil.instance.setWidth(10.0)),
//                      padding:
//                          EdgeInsets.all(ScreenUtil.instance.setWidth(6.0)),
//                      alignment: Alignment.center,
//                      decoration: BoxDecoration(
//                        border: new Border.all(
//                            color: Colors.deepOrangeAccent,
//                            width: ScreenUtil.instance.setWidth(1.0)), // 边色与边宽度
//                        color: Colors.deepOrangeAccent, // 底色
//                        borderRadius: new BorderRadius.circular(
//                            (ScreenUtil.instance.setWidth(20.0))), // 圆角度
//                      ),
//                      child: Text(
//                        Strings.MINE_ORDER_TAG_TWO,
//                        style: TextStyle(
//                            color: Colors.white,
//                            fontSize: ScreenUtil.instance.setSp(20.0)),
//                      ),
//                    )
//                  ],
//                )
                ],
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(
              left: ScreenUtil.instance.setWidth(20.0),
              right: ScreenUtil.instance.setWidth(20.0),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  "¥${good.price}",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: ScreenUtil.instance.setSp(24.0)),
                ),
                Padding(
                    padding: EdgeInsets.only(
                        top: ScreenUtil.instance.setHeight(20.0))),
                Text(
                  "X${good.number}",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: ScreenUtil.instance.setSp(24.0)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _showDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              Strings.TIPS,
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: ScreenUtil.instance.setSp(28.0)),
            ),
            content: Text(
              action == 1
                  ? Strings.MINE_ORDER_CANCEL_TIPS
                  : Strings.MINE_ORDER_DELETE_TIPS,
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: ScreenUtil.instance.setSp(28.0)),
            ),
            actions: <Widget>[
              FlatButton(
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    Strings.CANCEL,
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: ScreenUtil.instance.setSp(24.0)),
                  )),
              FlatButton(
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                    if (action == 1) {
                      _cancelOrder();
                    } else {
                      _deleteOrder();
                    }
                  },
                  child: Text(
                    Strings.CONFIRM,
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: ScreenUtil.instance.setSp(24.0)),
                  )),
            ],
          );
        });
  }

  _deleteOrder() {
    var parameters = {"orderId": widget.orderId};
    _mineService.deleteOrder(parameters, (success) {
      ToastUtil.showToast('删除成功');
      Navigator.of(context).pop(true);
    }, (error) {
      ToastUtil.showToast(error);
    });
  }

  _cancelOrder() {
    var parameters = {"orderId": widget.orderId};
    _mineService.cancelOrder(parameters, (success) {
      ToastUtil.showToast(Strings.MINE_ORDER_CANCEL_SUCCESS);
      setState(() {
        _orderDetailEntity.orderInfo.handleOption.cancel = false;
      });
    }, (error) {
      ToastUtil.showToast(error);
    });
  }

  ///继续支付
  void continuePay() async {
    _pay(order_sn) async {
      String _url = Api.DOMAIN + "/index/index/pre_order/?order_sn=" + order_sn;
      var h = HttpClient();
      h.badCertificateCallback = (cert, String host, int port) {
        return true;
      };
      var request = await h.getUrl(Uri.parse(_url));
      var response = await request.close();
      var data = await Utf8Decoder().bind(response).join();
      Map<String, dynamic> result = json.decode(data);
      fluwx
          .payWithWeChat(
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

    _pay(_orderDetailEntity.orderInfo.orderSn);
  }

//  void deleteOrder() async {}

  ///确认收货
  void confirmReceipt() async {
    var response = await HttpUtil.instance
        .get(Api.DOMAIN + "/index/index/updateOrderstatus", parameters: {
      "status": 401,
      "orderid": _orderDetailEntity.orderInfo.orderSn
    });
    if (response['errno'] == 0) {
      ToastUtil.showToast('收货成功');
      setState(() {
        refresh = !refresh;
        _queryOrderDetail();
      });
    } else {
      ToastUtil.showToast(response['errmsg']);
    }
  }
}

class _OrderButton extends StatelessWidget {
  final String orderStatus;
  final bool hidden;
  final void Function(String text) onTap;

  const _OrderButton(
      {Key key,
      @required this.hidden,
      @required this.orderStatus,
      @required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final text = _getButtonText();
    if (text == null || text.isEmpty || (hidden && orderStatus == "商家同意退款")) {
      return Container();
    }
    if (orderStatus == "未付款") {
      return Row(
        children: <Widget>[
          Expanded(
              child: MaterialButton(
            color: Colors.deepOrangeAccent,
            splashColor: Colors.deepOrange,
            minWidth: double.infinity,
            onPressed: () => onTap("继续支付"),
            child: Text(
              "继续支付",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenUtil.instance.setSp(30.0)),
            ),
          )),
          SizedBox(
            width: 32,
          ),
          Expanded(
              child: MaterialButton(
            color: Colors.deepOrangeAccent,
            splashColor: Colors.deepOrange,
            minWidth: double.infinity,
            onPressed: () => onTap("取消订单"),
            child: Text(
              "取消订单",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenUtil.instance.setSp(30.0)),
            ),
          )),
        ],
      );
    }
    if (orderStatus == "已取消" || orderStatus == "已取消(系统)") {
      return MaterialButton(
        color: Colors.deepOrangeAccent,
        splashColor: Colors.deepOrange,
        minWidth: double.infinity,
        onPressed: () => onTap(text),
        child: Text(
          text,
          style: TextStyle(
              color: Colors.white, fontSize: ScreenUtil.instance.setSp(30.0)),
        ),
      );
    }
    if (orderStatus != "已发货") {
      return MaterialButton(
        color: Colors.deepOrangeAccent,
        splashColor: Colors.deepOrange,
        minWidth: double.infinity,
        onPressed: () => onTap(text),
        child: Text(
          text,
          style: TextStyle(
              color: Colors.white, fontSize: ScreenUtil.instance.setSp(30.0)),
        ),
      );
    }
    return Row(
      children: <Widget>[
        Expanded(
            child: MaterialButton(
          color: Colors.deepOrangeAccent,
          splashColor: Colors.deepOrange,
          minWidth: double.infinity,
          onPressed: () => onTap("确认收货"),
          child: Text(
            "确认收货",
            style: TextStyle(
                color: Colors.white, fontSize: ScreenUtil.instance.setSp(30.0)),
          ),
        )),
        SizedBox(
          width: 32,
        ),
        Expanded(
            child: MaterialButton(
          color: Colors.deepOrangeAccent,
          splashColor: Colors.deepOrange,
          minWidth: double.infinity,
          onPressed: () => onTap("申请退款"),
          child: Text(
            "申请退款",
            style: TextStyle(
                color: Colors.white, fontSize: ScreenUtil.instance.setSp(30.0)),
          ),
        )),
      ],
    );
  }

  String _getButtonText() {
    switch (orderStatus) {
      case "未付款":
        return "继续支付";
      case "已发货":
        return "确认收货/申请退款";
      case "商家同意退款":
        return "填写退款快递信息";
      case "已取消":
      case "已取消(系统)":
        return "删除订单";
      default:
        return null;
    }
  }
}
