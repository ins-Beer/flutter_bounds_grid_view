
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

@immutable
class GridBounds {
  GridBounds(
    this.mainAxisPosition,
    this.crossAxisPosition,
    this.mainAxisExtent,
    this.crossAxisExtent
  ):  assert(mainAxisPosition != null && mainAxisPosition >= 0),
      assert(crossAxisPosition != null && crossAxisPosition >= 0),
      assert(mainAxisExtent != null && mainAxisExtent >= 0),
      assert(crossAxisExtent != null && crossAxisExtent >= 0);

  // 座標のスクロール方向の値
  final int mainAxisPosition;

  // 座標のスクロールと垂直の方向の値
  final int crossAxisPosition;

  // スクロール方向の終点の座標
  int get trailingMainAxisPosition {
    return mainAxisPosition + mainAxisExtent;
  }

  // スクロールと垂直の方向の終点の座標
  int get trailingCrossAxisPosition {
    return crossAxisPosition + crossAxisExtent;
  }

  // スクロール方向の幅
  final int mainAxisExtent;

  // スクロールと垂直の方向の幅
  final int crossAxisExtent;
}


class GridBoundsList {
  GridBoundsList(this.boundsList): assert(boundsList != null);
  
  /// [GridBounds]の配列。GridViewの全てのレイアウトが入っている。
  List<GridBounds> boundsList;

  /// 座標から合致する[GridBounds]を[boundsList]の中から探し、そのIndexを返す。
  /// 合致しない場合は-1を返す。
  int getIndexAtPosition(int _mainAxisPosition, int _crossAxisPosition) {
    assert(boundsList != null);
    assert(_mainAxisPosition != null && _mainAxisPosition >= 0);
    assert(_crossAxisPosition != null && _crossAxisPosition >= 0);
    for (int i = 0, len = boundsList.length; i < len; i++) {
      GridBounds bounds = boundsList[i];
      if (bounds.mainAxisPosition <= _mainAxisPosition &&
            _mainAxisPosition < bounds.trailingMainAxisPosition &&
              bounds.crossAxisPosition <= _crossAxisPosition &&
                _crossAxisPosition < bounds.trailingCrossAxisPosition) return i;
    }
    return -1;
  }

  /// [index]から[boundsList]の中にある[GridBounds]を返す。
  GridBounds getBoundsAtIndex(int index){
    assert(boundsList != null);
    assert(index != null && index >= 0);
    return (0 <= index && index < boundsList.length) ? boundsList[index] : null;
  }

  /// 全ての[GridBounds]から算出された、スクロール方向の領域数を算出する。
  int get mainAxisCount {
    assert(boundsList != null);
    int maxCount = 0;
    for (int i = 0, length = this.boundsList.length; i < length; i++) {
      final GridBounds bounds = this.boundsList[i];
      maxCount = math.max(maxCount, bounds.mainAxisPosition + bounds.mainAxisExtent).toInt();
    }
    return maxCount;
  }

  /// 全ての[GridBounds]から算出された、スクロールと垂直の方向の領域数を算出する。
  int get crossAxisCount {
    assert(boundsList != null);
    int maxCount = 0;
    for (int i = 0, length = this.boundsList.length; i < length; i++) {
      final GridBounds bounds = this.boundsList[i];
      maxCount = math.max(maxCount, bounds.crossAxisPosition + bounds.crossAxisExtent).toInt();
    }
    return maxCount;
  }

  /// [boundsList]の順番を上から左からの順番に直す。その際に引数の[children]も同じように並べなおす。
  /// 並べ直された[List<Widget>]を返す。
  List<Widget> sort(List<Widget> children) {
    assert(boundsList != null);
    assert(children.length <= boundsList.length);

    List<int> indexes = [];
    for (int i = 0, len = children.length; i < len; i++) {
      indexes.add(i);
    }
    indexes.sort((a, b) => _compare(boundsList[a], boundsList[b]));
    List<Widget> sortedChildren = [];
    indexes.forEach((index)=> sortedChildren.add(children[index]));
    
    List<GridBounds> _boundsList = [];
    indexes.forEach((index)=> _boundsList.add(boundsList[index]));
    boundsList = _boundsList;
    return sortedChildren;
  }

  /// [sort]で使用されるプライベートメソッド。[GridBounds]を上から左からの順番に直るようなcompare関数。
  int _compare(GridBounds a, GridBounds b) {
    int _crossAxisCount = crossAxisCount;
    int mainAxisPositionDiff = (a.mainAxisPosition - b.mainAxisPosition) * _crossAxisCount;
    int crossAxisPositionDiff = a.crossAxisPosition - b.crossAxisPosition;
    return mainAxisPositionDiff + crossAxisPositionDiff;
  }

  /// boundsListの最後のIndexを返す。
  int get lastIndex {
    assert(boundsList != null);
    return boundsList.length - 1;
  }

}


class SliverGridBoundsLayout extends SliverGridLayout {

  const SliverGridBoundsLayout({
    @required this.boundsList,
    @required this.mainAxisStride,
    @required this.crossAxisStride,
    @required this.childMainAxisExtent,
    @required this.childCrossAxisExtent,
    @required this.reverseCrossAxis,
  }) : assert(boundsList != null),
       assert(mainAxisStride != null && mainAxisStride >= 0),
       assert(crossAxisStride != null && crossAxisStride >= 0),
       assert(childMainAxisExtent != null && childMainAxisExtent >= 0),
       assert(childCrossAxisExtent != null && childCrossAxisExtent >= 0),
       assert(reverseCrossAxis != null);

  /// The number of children in the cross axis.
  final GridBoundsList boundsList;

  /// The number of pixels from the leading edge of one tile to the leading edge
  /// of the next tile in the main axis.
  final double mainAxisStride;

  /// The number of pixels from the leading edge of one tile to the leading edge
  /// of the next tile in the cross axis.
  final double crossAxisStride;

  /// The number of pixels from the leading edge of one tile to the trailing
  /// edge of the same tile in the main axis.
  final double childMainAxisExtent;

  /// The number of pixels from the leading edge of one tile to the trailing
  /// edge of the same tile in the cross axis.
  final double childCrossAxisExtent;

  /// Whether the children should be placed in the opposite order of increasing
  /// coordinates in the cross axis.
  ///
  /// For example, if the cross axis is horizontal, the children are placed from
  /// left to right when [reverseCrossAxis] is false and from right to left when
  /// [reverseCrossAxis] is true.
  ///
  /// Typically set to the return value of [axisDirectionIsReversed] applied to
  /// the [SliverConstraints.crossAxisDirection].
  final bool reverseCrossAxis;

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    final int scrollOffsetMainAxisPosition = mainAxisStride > 0.0 ? scrollOffset ~/ mainAxisStride : 0;
    final int crossAxisCount = boundsList.crossAxisCount;
    int index = boundsList.lastIndex;
    for (int crossAxisPosition = 0; crossAxisPosition < crossAxisCount; crossAxisPosition++) {
      int _index = boundsList.getIndexAtPosition(scrollOffsetMainAxisPosition, crossAxisPosition);
      if (_index >= 0) {
        index = math.min(index, _index);
      }
    }
    return 0;
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    final int scrollOffsetMainAxisPosition = mainAxisStride > 0.0 ? (scrollOffset / mainAxisStride).ceil() : 0;
    final int mainAxisCount = boundsList.mainAxisCount;
    final int crossAxisCount = boundsList.crossAxisCount;

    if (mainAxisCount - 1 <= scrollOffsetMainAxisPosition) {
      return boundsList.lastIndex;
    }
    int index = 0;
    for (int crossAxisPosition = crossAxisCount - 1; crossAxisPosition >= 0; crossAxisPosition--) {
      int _index = boundsList.getIndexAtPosition(scrollOffsetMainAxisPosition, crossAxisPosition);
      if (_index >= 0) {
        return math.max(index, _index);
      }
    }
    return 0;
  }

  double _getOffsetFromStartInCrossAxis(double crossAxisStart) {
    if (reverseCrossAxis)
      return boundsList.crossAxisCount * crossAxisStride - crossAxisStart - childCrossAxisExtent;
    return crossAxisStart;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    GridBounds bounds = boundsList.getBoundsAtIndex(index);
    final double crossAxisStart = bounds.crossAxisPosition * crossAxisStride;
    final double mainAxisSpacing = mainAxisStride - childMainAxisExtent;
    final double crossAxisSpacing = crossAxisStride - childCrossAxisExtent;

    return SliverGridGeometry(
      scrollOffset: bounds.mainAxisPosition * mainAxisStride,
      crossAxisOffset: _getOffsetFromStartInCrossAxis(crossAxisStart),
      mainAxisExtent: childMainAxisExtent * bounds.mainAxisExtent + (bounds.mainAxisExtent - 1) * mainAxisSpacing,
      crossAxisExtent: childCrossAxisExtent * bounds.crossAxisExtent + (bounds.crossAxisExtent - 1) * crossAxisSpacing,
    );
  }

  @override
  double computeMaxScrollOffset(int childCount) {
    assert(childCount != null);
    final int mainAxisCount = boundsList.mainAxisCount;
    final double mainAxisSpacing = mainAxisStride - childMainAxisExtent;
    return mainAxisStride * mainAxisCount - mainAxisSpacing;
  }
}


class SliverGridDelegateWithBounds extends SliverGridDelegate {

  const SliverGridDelegateWithBounds({
    @required this.boundsList,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
  }) : assert(boundsList != null),
       assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
       assert(crossAxisSpacing != null && crossAxisSpacing >= 0),
       assert(childAspectRatio != null && childAspectRatio > 0);

  final GridBoundsList boundsList;

  final double mainAxisSpacing;

  final double crossAxisSpacing;

  final double childAspectRatio;

  bool _debugAssertIsValid() {
    assert(boundsList != null);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    assert(childAspectRatio > 0.0);
    return true;
  }

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    assert(_debugAssertIsValid());
    final int crossAxisCount = boundsList.crossAxisCount;
    final double usableCrossAxisExtent = constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    final double childMainAxisExtent = childCrossAxisExtent / childAspectRatio;
    return SliverGridBoundsLayout(
      boundsList: boundsList,
      mainAxisStride: childMainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(SliverGridDelegateWithBounds oldDelegate) {
    return oldDelegate.boundsList != boundsList
        || oldDelegate.mainAxisSpacing != mainAxisSpacing
        || oldDelegate.crossAxisSpacing != crossAxisSpacing
        || oldDelegate.childAspectRatio != childAspectRatio;
  }
}