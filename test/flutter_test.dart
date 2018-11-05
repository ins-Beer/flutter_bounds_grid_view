// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:math' as math;
import 'package:flutter_bounds_grid_view/flutter_bounds_grid_view.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new FirstPageWidget(),
    );
  }
}

class FirstPageWidget extends StatefulWidget {
  FirstPageWidget({Key key}) : super(key: key);

  @override
  _FirstPageWidgetState createState() => new _FirstPageWidgetState();
}

class _FirstPageWidgetState extends State<FirstPageWidget> {

  Widget generateBody(BuildContext context) {
    List<GridBounds> boundsList = [];
    List<Widget> children = [];

    // 列数
    const int CROSS_AXIS_COUNT = 10;
    // 行数
    const int MAIN_AXIS_COUNT = 100;

    // Widgetの最大サイズ
    const int MAX_EXTENT = 3;

    // 領域マップの2次元配列 初期値は-1で埋める
    List<List<int>> indexMap = [];
    for (int i = 0; i < MAIN_AXIS_COUNT; i++) {
      indexMap.add(List<int>.filled(CROSS_AXIS_COUNT, -1));
    }
    
    // アイテム数のカウント
    int itemCount = 0;
    
    // 二次元配列を1セルずつみていく
    for (int y = 0; y < MAIN_AXIS_COUNT; y++) {
      for (int x = 0; x < CROSS_AXIS_COUNT; x++) {
        // -1じゃなかったらすでにマッピングされているのでスルー
        if (indexMap[y][x] >= 0) continue;
        // 今の座標で下に広がれる最大値 <= 3 を取得。
        final int maxMainAxisExtent = math.min(MAX_EXTENT, MAIN_AXIS_COUNT - y);
        // 今の座標で右に広がれる最大値 <= 3 を取得。
        final int maxCrossAxisExtent = math.min(MAX_EXTENT, CROSS_AXIS_COUNT - x);
        // この座標の領域の高さをランダムで生成
        int mainAxisExtent = math.Random().nextInt(maxMainAxisExtent) + 1;
        // この座標の領域の幅をランダムで生成
        int crossAxisExtent = math.Random().nextInt(maxCrossAxisExtent) + 1;
        
        // 領域マップにIndexを書き込む
        for (int yy = 0; yy < mainAxisExtent; yy++) {
          for (int xx = 0; xx < crossAxisExtent; xx++) {
            if (indexMap[y + yy][x + xx] >= 0) {
              crossAxisExtent = xx;
              continue;
            }
            indexMap[y + yy][x + xx] = itemCount;
          }
        }
        // 座標と領域の大きさからGridBoundsを生成し配列へ
        boundsList.add(GridBounds(y, x, mainAxisExtent, crossAxisExtent));
        // Indexを表示するテキスト（背景青）
        children.add(Container(
          child: Text(itemCount.toString(),style: TextStyle(fontSize: 16.0, color: Colors.white),),
          alignment: Alignment.center,
          color: Color.fromARGB(255, 45, 120, 220),
        ));
        // Indexのインクリメント
        itemCount++;
      }
    }
    // GridBoundsListの生成
    GridBoundsList gridBoundsList = GridBoundsList(boundsList);
    // gridBoundsListのsortを使用して並べ替えたWidget配列を取得
    List<Widget> sortedChildren = gridBoundsList.sort(children);

    // 例のDelegateを使ってGridViewを生成
    return GridView(
      gridDelegate: SliverGridDelegateWithBounds(
        boundsList: gridBoundsList,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.0,
        crossAxisSpacing: 1.0,
      ),
      children: sortedChildren,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("BoundsGridViewTest")),
      body: this.generateBody(context),
    );
  }
}
