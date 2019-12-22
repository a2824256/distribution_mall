import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mall/entity/home_entity.dart';
import 'package:mall/constant/string.dart';
import 'package:mall/utils/navigator_util.dart';
import 'package:mall/widgets/cached_image.dart';

class PayResult extends StatefulWidget {

  @override
  PayResultState createState() => PayResultState();
}

class PayResultState extends State<PayResult> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            child: Center(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text('支付成功')
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
