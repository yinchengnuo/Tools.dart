library tools;

import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_view/photo_view.dart';

class Tools {
  static MediaQueryData mediaQuery = MediaQueryData.fromWindow(window);
  static double width = mediaQuery.size.width;
  static double height = mediaQuery.size.height;
  static EdgeInsets padding = mediaQuery.padding;

  static px(number) => number * width / 750;

  // 生成自定义 appBar
  static appBar(context, {back: true, title: '', action: false, transparent: false}) => PreferredSize(
        preferredSize: Size.fromHeight(Tools.px(86)),
        child: AppBar(
          title: GestureDetector(onLongPress: () => Navigator.of(context).pushNamed('/icon'), child: Text(title)),
          centerTitle: true,
          brightness: Brightness.light,
          automaticallyImplyLeading: false,
          elevation: transparent == false ? px(1) : 0,
          backgroundColor: transparent == false ? Colors.white : Colors.transparent,
          leading: back ? IconButton(icon: Icon(Icons.arrow_back_ios, size: Tools.px(40)), onPressed: () => Navigator.of(context).pop()) : null,
          actions: action == false ? <Widget>[] : <Widget>[action],
        ),
      );

  // 格式化时间
  static formatTime(time, {array: false}) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(time.toString()));
    final arr = [
      date.year.toString().length == 1 ? '0${date.year.toString()}' : date.year.toString(),
      date.month.toString().length == 1 ? '0${date.month.toString()}' : date.month.toString(),
      date.weekday.toString().length == 1 ? '0${date.weekday.toString()}' : date.weekday.toString(),
      date.day.toString().length == 1 ? '0${date.day.toString()}' : date.day.toString(),
      date.hour.toString().length == 1 ? '0${date.hour.toString()}' : date.hour.toString(),
      date.minute.toString().length == 1 ? '0${date.minute.toString()}' : date.minute.toString()
    ];
    return array ? arr : '${arr[0]}-${arr[1]}-${arr[3]} ${arr[4]}:${arr[5]}';
  }

  // 数字打点
  static String numDot(string) => string.toString().replaceAllMapped(RegExp(r"(\d)(?=(?:\d{3})+\b)"), (match) => '${match.group(1)},');

  // 取数组最大数值
  static double maxOfList(list) {
    double max = 0;
    list.forEach((item) {
      item += 0.0;
      if (item > max) {
        max = item;
      }
    });
    return max;
  }

  // 颜色字符串转 Color
  static Color getColor(string) => Color(int.parse(string.toString().replaceAll('#', ''), radix: 16)).withAlpha(255);

  // 等待不为 null 时取值
  static String waitString(data, key) => data == null ? '' : data[key].toString();

  // 克隆
  static clone(map) => map is String ? jsonDecode(map) : jsonDecode(jsonEncode(map));
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// 自定义回弹效果
class MyScrollBehavior extends ScrollBehavior {
  final Color color;
  MyScrollBehavior({this.color});

  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    if (Platform.isAndroid || Platform.isFuchsia) {
      return this.color == null ? child : GlowingOverscrollIndicator(child: child, axisDirection: axisDirection, color: this.color);
    } else {
      return super.buildViewportChrome(context, child, axisDirection);
    }
  }
}

// 自定义小圆点
class RedDot extends StatelessWidget {
  final number;
  const RedDot({Key key, this.number}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return this.number > 0
        ? ConstrainedBox(
            constraints: BoxConstraints(minWidth: Tools.px(24)),
            child: Container(
              height: Tools.px(30),
              alignment: Alignment(0, 0),
              padding: EdgeInsets.symmetric(horizontal: Tools.px(8)),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(Tools.px(Tools.px(30)))),
              child: Text(this.number > 999 ? '999+' : this.number.toString(), style: TextStyle(fontSize: Tools.px(25), color: Colors.white)),
            ),
          )
        : Container(width: 0, height: 0);
  }
}

// 自定义页面 loading
class Loading extends StatelessWidget {
  final loading, child;
  const Loading({Key key, this.loading = false, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          this.child,
          this.loading
              ? Container(alignment: Alignment(0, 0), color: Color.fromRGBO(0, 0, 0, 0.1), child: CircularProgressIndicator())
              : Container(width: 0, height: 0)
        ],
      ),
    );
  }
}

// 封装过的水波纹类
class MaterialInkWell extends StatelessWidget {
  final onTap, onLongPress, onTapCancel, child, padding, borderRadius;
  const MaterialInkWell({Key key, this.onTap, this.child, this.padding, this.onLongPress, this.onTapCancel, this.borderRadius}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Padding(padding: this.padding == null ? EdgeInsets.all(0) : this.padding, child: this.child),
        Material(color: Colors.transparent, child: InkWell(onTap: this.onTap, onLongPress: this.onLongPress))
      ],
    );
  }
}

// 路由动画（淡入）
class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(opacity: animation, child: child),
        );
}

// 图片预览
class PreviewImage extends StatelessWidget {
  const PreviewImage({
    this.imageProvider, //图片
    this.backgroundDecoration, //背景修饰
    this.minScale, //最大缩放倍数
    this.maxScale, //最小缩放倍数
    this.heroTag, //hero动画tagid
  });
  final ImageProvider imageProvider;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: PhotoView(
                imageProvider: imageProvider,
                backgroundDecoration: backgroundDecoration,
                minScale: minScale,
                maxScale: maxScale,
                heroAttributes: PhotoViewHeroAttributes(tag: heroTag),
                enableRotation: true,
              ),
            ),
            Positioned(
              //右上角关闭按钮
              right: 10,
              top: MediaQuery.of(context).padding.top,
              child: IconButton(
                icon: Icon(Icons.close, size: 30, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
