import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mall/constant/string.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mall/utils/http_util.dart';
import 'package:mall/utils/navigator_util.dart';
import 'package:mall/widgets/divider_line.dart';
import 'package:mall/utils/toast_util.dart';
import 'package:mall/service/mine_service.dart';
import 'package:dio/dio.dart';
import 'package:mall/utils/shared_preferences_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mall/api/api.dart';

class GoodsEvaluationView extends StatefulWidget {
  final String goodsName;

  final int goodsId;

  final String orderSn;

  final int productId;

  const GoodsEvaluationView(
      {Key key,
      @required this.goodsName,
      @required this.goodsId,
      @required this.orderSn,
      @required this.productId
      })
      : super(key: key);

  @override
  _GoodsEvaluationViewState createState() => _GoodsEvaluationViewState();
}

class _GoodsEvaluationViewState extends State<GoodsEvaluationView> {

  TextEditingController _contentController = TextEditingController();
  String json = '';
  List<String> _paths = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("商品评价"),
          centerTitle: true,
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                left: ScreenUtil.instance.setWidth(20.0),
                right: ScreenUtil.instance.setWidth(20.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: ScreenUtil.instance.setHeight(100.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 200,
                        child: Text(
                          widget.goodsName ?? "商品名称",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: ScreenUtil.instance.setSp(26.0)),
                        ),
                      ),
                    ],
                  ),
                ),
                DividerLineView(),
                Container(
                  margin: EdgeInsets.all(ScreenUtil.instance.setWidth(20.0)),
                  width: double.infinity,
                  height: ScreenUtil.instance.setHeight(300.0),
                  child: TextField(
                    controller: _contentController,
                    maxLines: 10,
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: ScreenUtil.instance.setSp(26.0)),
                    decoration: InputDecoration(
                      hintText: Strings.FEEDBACK_HINT_TEXT,
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: ScreenUtil.instance.setSp(26.0)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.grey,
                            width: ScreenUtil.instance.setWidth(1.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.grey,
                            width: ScreenUtil.instance.setWidth(1.0)),
                      ),
                    ),
                  ),
                ),
                //todo 图片
                Container(
                  margin: EdgeInsets.all(ScreenUtil.instance.setWidth(20.0)),
                  child: UploadPicWidget(
                    onUploadSuccess: (paths) {
                      _paths = paths;
                    },
                  ),
                ),
                Container(
                  height: ScreenUtil.instance.setHeight(100.0),
                  margin:
                      EdgeInsets.only(top: ScreenUtil.instance.setHeight(100)),
                  padding: EdgeInsets.only(
                      left: ScreenUtil.instance.setWidth(20),
                      right: ScreenUtil.instance.setWidth(20)),
                  child: MaterialButton(
                    color: Colors.deepOrangeAccent,
                    splashColor: Colors.deepOrange,
                    minWidth: double.infinity,
                    onPressed: () => _submit(),
                    child: Text(
                      Strings.SUBMIT,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil.instance.setSp(30.0)),
                    ),
                  ),
                )
              ],
            ),
          ),
        )));
  }

  _listToJson(String element){
    if(json == ''){
      json = '"${element}",';
    }else{
      json = '${json}"${element}",';
    }
  }

  _submit() async {
    if (_contentController.text.isEmpty) {
      ToastUtil.showToast(Strings.FEEDBACK_HINT_TEXT);
      return;
    }
    _paths.forEach(_listToJson);
    try{
      json = json.substring(0,json.length - 1);
    }catch(e){
      json = '';
    }
    SharedPreferences sharedPreferences =
    await SharedPreferences.getInstance();
    String nickname = sharedPreferences.getString(Strings.NICK_NAME);
    print('发送');
    print(widget.productId);
    var params = {
      "username": nickname,
      "goods_id": widget.goodsId,
      "order_sn": widget.orderSn,
      "product_id": widget.productId,
      "content":_contentController.text,
      "pic_urls":'[${json}]',
    };
    var response= await HttpUtil.instance.post(
        Api.DOMAIN+"/index/index/newComment",
        parameters: params);
    if (response['errno'] == 0) {
      ToastUtil.showToast('评论成功');
      NavigatorUtils.popRegister(context);
    } else {
      ToastUtil.showToast(response['errmsg']);
    }
  }
}

/// 上传图片
class UploadPicWidget extends StatefulWidget {
  final void Function(List<String> paths) onUploadSuccess;

  const UploadPicWidget({Key key, @required this.onUploadSuccess})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _UploadPicWidgetState();
  }
}

class _UploadPicWidgetState extends State<UploadPicWidget> {
  List<File> _imgages = [];
  bool showLoading = false;

  List<String> _imagesPath = [];

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    ///上传图片
    _upLoadImage(image);
  }

  _upLoadImage(File image) async {
    setState(() {
      showLoading = true;
    });
    String path = image.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    FormData formData =
        new FormData.from({"file": new UploadFileInfo(new File(path), name)});
    Dio dio = new Dio();
    var response = await dio.post<String>(
        Api.DOMAIN+ "/index/mall/uploadPic",
        data: formData);
    if (response.statusCode == 200) {
      print(response.data);
      var result = jsonDecode(response.data);
      if (result["errno"] == 0) {
        _imagesPath.add(result["imgpath"]);
        widget.onUploadSuccess(_imagesPath);
        //上传成功
        setState(() {
          _imgages.add(image);
        });
      }
    }
    setState(() {
      showLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoading) {
      return Container(
          child: Center(
              child: CircularProgressIndicator(
        backgroundColor: Colors.deepOrange,
      )));
    }
    List<Widget> children = [];
    List<Widget> images = _imgages
        .map((file) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 80,
                height: 80,
                child: Image.file(
                  file,
                  fit: BoxFit.fill,
                ),
              ),
            ))
        .toList();
    children.addAll(images);
    if (images.length < 3) {
      children.add(GestureDetector(
        onTap: getImage,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(border: Border.all()),
          child: Icon(Icons.add),
        ),
      ));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
