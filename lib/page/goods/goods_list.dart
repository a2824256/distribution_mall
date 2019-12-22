import 'package:flutter/material.dart';
import 'package:mall/constant/string.dart';
import 'package:mall/entity/goods_entity.dart';
import 'package:mall/service/goods_service.dart';
import 'package:mall/utils/navigator_util.dart';
import 'package:mall/widgets/cached_image.dart';

class GoodsList extends StatefulWidget {
  int categoryId;

  GoodsList(this.categoryId);

  @override
  _GoodsListState createState() => _GoodsListState();
}

class _GoodsListState extends State<GoodsList> {
  GoodsService goodsService = GoodsService();
  List<GoodsEntity> goodsEntitys = List();
  var categoryId;

  _getGoodsData(int categoryId) {
    goodsService.getCategoryGoodsListData(
        {"categoryId": categoryId, "page": 1, "limit": 100}, (goodsEntityList) {
      setState(() {
        print('goodsEntityList');
        print(goodsEntityList);
        goodsEntitys = goodsEntityList;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    if (goodsEntitys == null || goodsEntitys.length == 0) {
      categoryId = widget.categoryId;
      _getGoodsData(categoryId);
      print("GoodsList_initState");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//        key: ObjectKey("${categoryId}"),
        body: Container(
      padding: EdgeInsets.only(left: 4.0, right: 4.0),
      child: Center(
        child: goodsEntitys != null && goodsEntitys.length != 0
            ? GridView.builder(
                itemCount: goodsEntitys == null ? 0 : goodsEntitys.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
//                    mainAxisSpacing: 6.0,
//                    crossAxisSpacing: 6.0,
                    childAspectRatio: 0.9),
                itemBuilder: (BuildContext context, int index) {
                  return getGoodsItemView(goodsEntitys[index]);
                })
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      "images/no_data.png",
                      height: 80,
                      width: 80,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                    ),
                    Text(
                      Strings.NO_DATA_TEXT,
                      style: TextStyle(
                          fontSize: 16.0, color: Colors.deepOrangeAccent),
                    )
                  ],
                ),
              ),
      ),
    ));
  }

  Widget getGoodsItemView(GoodsEntity goodsEntity) {
    return InkWell(
      child: Container(
        alignment: Alignment.center,
        child: Card(
          elevation: 2.0,
          margin: EdgeInsets.all(6.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(5.0),
                  child: CachedImageView(
                    120,
                    480,
                    goodsEntity.picUrl,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4.0),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 4.0,
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  goodsEntity.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black54, fontSize: 12.0),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 4.0, top: 4.0, bottom: 8),
                alignment: Alignment.center,
                child: Text(
                  "￥${goodsEntity.retailPrice}",
                  style: TextStyle(color: Colors.red, fontSize: 12.0),
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () => _itemClick(goodsEntity.id),
    );
  }

  _itemClick(int id) {
    NavigatorUtils.goGoodsDetails(context, id);
  }
}
