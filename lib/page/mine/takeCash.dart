import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mall/api/api.dart';
import 'package:mall/utils/http_util.dart';
import 'package:mall/utils/toast_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class takeCashView extends StatefulWidget {
  @override
  _takeCashViewState createState() => _takeCashViewState();
}

class _takeCashViewState extends State<takeCashView> {
  String _name = "";

  String _alipay = "";

  String _amount = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('提现信息'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          TextField(
            autofocus: true,
            decoration: InputDecoration(
                labelText: "真实姓名",
                hintText: "真实姓名",
                prefixIcon: Icon(Icons.person)),
            onChanged: (s) => _name = s,
          ),
          TextField(
            autofocus: true,
            decoration: InputDecoration(
                labelText: "收款人银行账号",
                hintText: "银行账号",
                prefixIcon: Icon(Icons.account_balance_wallet)),
            onChanged: (s) => _alipay = s,
          ),
          TextField(
            autofocus: true,
            decoration: InputDecoration(
                labelText: "金额",
                hintText: "请填写小于可提现金额的数据",
                prefixIcon: Icon(Icons.person)),
            onChanged: (s) => _amount = s,
          ),
          SizedBox(
            height: 16,
          ),
          Center(
              child: InkWell(
            onTap: _tryTakeCash,
            child: Chip(
                label: Text(
                  '            提现            ',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil.instance.setSp(26.0)),
                ),
                backgroundColor: Colors.deepOrangeAccent),
          ))
        ],
      ),
    );
  }

  ///提现
  void _tryTakeCash() async {
    if (_name.isEmpty || _alipay.isEmpty || _amount.isEmpty) {
      ToastUtil.showToast("请检查输入信息");
      return;
    }
    try {
      if (int.parse(_amount) < 10) {
        ToastUtil.showToast("提现金额不得少于10元");
        return;
      }
    } catch (e) {
      ToastUtil.showToast("请输入正确金额");
      return;
    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int userid = await sharedPreferences.getInt('userid');
    var result = await HttpUtil.instance
        .post(Api.DOMAIN + "/index/index/canshout", parameters: {
      "userid": userid,
      "username": _name,
      "alipay_id": _alipay,
      "cash": _amount,
    });
    if (result['errno'] == 0) {
      ///成功
      ToastUtil.showToast(result['errmsg']);
      Navigator.pop(context);
    } else {
      ///失败
      if (result['errmsg'] != null) ToastUtil.showToast(result['errmsg']);
    }
  }
}
