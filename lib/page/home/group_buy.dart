import 'package:flutter/material.dart';
import 'package:mall/entity/home_entity.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mall/widgets/cached_image.dart';
import 'package:mall/utils/navigator_util.dart';

class GroupBuyView extends StatelessWidget {
  List<GrouponList> groupEntitys;

  GroupBuyView(this.groupEntitys);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: groupEntitys.length,
        itemBuilder: (BuildContext context, int index) {
          return _getGroupBuyItem(context, groupEntitys[index]);
        });
  }

  Widget _getGroupBuyItem(BuildContext context, GrouponList groupBuyEntity) {
    print(groupBuyEntity.id);
    return Card(
        child: InkWell(
      onTap: () {
        NavigatorUtils.goGoodsDetails(context, groupBuyEntity.id);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CachedImageView(ScreenUtil.instance.setWidth(120.0),
                ScreenUtil.instance.setWidth(120.0), groupBuyEntity.picUrl),
            Padding(
              padding: EdgeInsets.only(
                left: ScreenUtil.instance.setWidth(20.0),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      groupBuyEntity.name,
                      style: TextStyle(
                          fontSize: ScreenUtil.instance.setSp(26.0),
                          color: Colors.black87),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: ScreenUtil.instance.setWidth(10.0)),
                  ),
                  Text(
                    groupBuyEntity.brief,
                    style: TextStyle(
                        fontSize: ScreenUtil.instance.setSp(26.0),
                        color: Colors.black54),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: ScreenUtil.instance.setWidth(10.0)),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        "专柜价${groupBuyEntity.counterPrice}",
                        style: TextStyle(
                            fontSize: ScreenUtil.instance.setSp(24.0),
                            color: Colors.grey[850],
                            decoration: TextDecoration.lineThrough,
                            decorationStyle: TextDecorationStyle.dashed),
                      ),
                      SizedBox(width: 8,),
                      Expanded(
                        child: Text(
                          "抢购价${groupBuyEntity.grouponPrice}",
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: ScreenUtil.instance.setSp(24.0),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      // 火热抢购中
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                                left: ScreenUtil.instance.setWidth(10.0),
                                right: ScreenUtil.instance.setWidth(10.0)),
                            height: ScreenUtil.instance.setHeight(48.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: new Border.all(
                                    color: Colors.deepOrangeAccent, width: 0.5),
                                // 边色与边宽度
                                borderRadius: BorderRadius.circular(6.0),
                                color: Colors.white),
                            child: Text(
                              "火热抢购中",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: ScreenUtil.instance.setSp(26.0)),
                            ),
                          ),
                          SizedBox(width: 16,)
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
