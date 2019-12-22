import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mall/constant/string.dart';
import 'package:mall/utils/http_util.dart';
import 'package:mall/utils/string_util.dart';
import 'package:mall/api/api.dart';

class GoodsCommentsPage extends StatelessWidget {
  final int goodId;

  const GoodsCommentsPage({Key key, @required this.goodId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("商品评论"),
        centerTitle: true,
      ),
      body: _CommentsList(
        id: goodId,
      ),
    );
  }
}

class _CommentsList extends StatefulWidget {
  final int id;

  const _CommentsList({Key key, this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CommentListViewState();
  }
}

class _CommentListViewState extends State<_CommentsList> {
  bool isEmpty = false;
  bool isLoading = true;
  int page = 0;

  bool _isGetData = false;
  List _comments = [];
  bool noMore =false;

  EasyRefreshController _controller = EasyRefreshController();

  @override
  void initState() {
    super.initState();
    _comments.clear();
    page = 0;
    _getCommentData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (isLoading) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (isEmpty) {
      return empty();
    }
    return EasyRefresh(
      controller: _controller,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return _buildItems(context, _comments[index]);
        },
        itemCount: _comments.length,
      ),
      onLoad: ()async{_getCommentData();},
    );
  }

  Widget empty() {
    return Center(
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
            style: TextStyle(fontSize: 16.0, color: Colors.deepOrangeAccent),
          )
        ],
      ),
    );
  }

  void _getCommentData() async {
    if (_isGetData&&noMore) {
      return;
    }
    _isGetData = true;
    var response = await HttpUtil.instance.get(
        Api.DOMAIN+"/index/index/getComments/?page=$page&limit=10&goodsId=${widget.id}");
    if (response['errno'] == 0) {
      if (response['data'].length != 0) {
        //没有更多了
        setState(() {
          _comments.addAll(response['data']);
          page++;
        });
      } else {
        noMore = true;
      }
    }
    _isGetData = false;
    isLoading = false;
    _controller.finishLoad();
  }

  Widget _buildItems(BuildContext context, comment) {
    final font = TextStyle(color: Colors.black54, fontSize: 14);
    List _images = jsonDecode(comment["pic_urls"]);
    List<Widget> images = _images
        .map((url) => Padding(
      padding: const EdgeInsets.only(right: 16),
      child: SizedBox(
        width: 80,
        height: 80,
        child: Image.network(
          url,
          fit: BoxFit.fill,
        ),
      ),
    )).toList();
    String name=  '用戶名: ${comment["nickname"]}';
    if(StringUtils.isPhoneSimple(name)){
      name = name.substring(0,3)+" ***** "+name.substring(7,name.length-1);
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 8),
            child: Text(
              name,
              style: font,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 16, bottom: 16),
            child: Text(
              '评论: ${comment["content"]}',
              style: font,
            ),
          ),
          //图片
          images.isEmpty?SizedBox():Row(
            mainAxisSize: MainAxisSize.min,
            children: images,
          ),
          //todo 回复
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 16,),
            child: Text(
              comment["update_time"],
              style: font,
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
