import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PersonRowView extends StatelessWidget {
  var leftText;
  var finalText;

  PersonRowView(this.leftText,this.finalText);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Container(
        height: ScreenUtil.instance.setHeight(80.0),
        child: Row(
          children: <Widget>[
            Text(
              leftText,
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
                    finalText,
                    style: TextStyle(
                        color: Colors.black45,
                        fontSize: ScreenUtil.instance.setSp(26.0)),
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
    );
  }
}
