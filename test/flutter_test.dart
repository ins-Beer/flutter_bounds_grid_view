// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bounds_grid_view/bounds_grid_view.dart';

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
      home: new CalcRootWidget(),
    );
  }
}

enum OPERATOR_IDENTIFIER {
  PLUS,
  SUBTRACT,
  MULTIPLY,
  DIVIDE,
  NONE,
}

class CalcRootWidget extends StatefulWidget {
  CalcRootWidget({Key key}) : super(key: key);

  @override
  _CalcRootWidgetState createState() => new _CalcRootWidgetState();
}

class _CalcRootWidgetState extends State<CalcRootWidget> {
  double currentNumber = 0.0;
  double bufferNumber = 0.0;
  String displayNumber = "0";
  OPERATOR_IDENTIFIER mode = OPERATOR_IDENTIFIER.NONE;
  bool nextClear = false;
  bool point = false;

  int _point = 1;

  void operandClicked(int number) {
    setState(() {
      if (nextClear) {
        this.currentNumber = 0.0;
        this.nextClear = false;
      }
      if (number == 10 || number == 100) {
        if (this.point) {
          this._point *= number;
        } else {
          this.currentNumber *= number;
        }
      } else {
        if (this.point) {
          this._point *= 10;
          this.currentNumber += number / this._point;
        } else {
          this.currentNumber *= 10;
          this.currentNumber += number;
        }
      }

      if (this._point == 1) {
        this.displayNumber = this.currentNumber.floor().toString();
      } else {
        this.displayNumber = this.currentNumber.toString();
      }
    });
  }

  void operatorClicked(OPERATOR_IDENTIFIER identifier) {
    setState(() {
      this.nextClear = true;
      this.point = false;
      this._point = 1;
      switch (this.mode) {
        case OPERATOR_IDENTIFIER.PLUS:
          this.currentNumber = this.currentNumber + this.bufferNumber;
          break;
        case OPERATOR_IDENTIFIER.SUBTRACT:
          this.currentNumber = this.currentNumber - this.bufferNumber;
          break;
        case OPERATOR_IDENTIFIER.MULTIPLY:
          this.currentNumber = this.currentNumber * this.bufferNumber;
          break;
        case OPERATOR_IDENTIFIER.DIVIDE:
          this.currentNumber = this.bufferNumber / this.currentNumber;
          break;
        case OPERATOR_IDENTIFIER.NONE:
          break;
      }
      this.mode = identifier;
      this.bufferNumber = currentNumber;

      if (this.currentNumber % 1 == 0) {
        this.displayNumber = this.currentNumber.floor().toString();
      } else {
        this.displayNumber = this.currentNumber.toString();
      }
    });
  }

  void allClear() {
    setState(() {
      this.nextClear = false;
      this.currentNumber = 0.0;
      this.bufferNumber = 0.0;
      this._point = 1;
      this.point = false;
      this.displayNumber = "0";
    });
  }

  void currentClear() {
    setState(() {
      this.currentNumber = 0.0;
      this._point = 1;
      this.point = false;
      this.displayNumber = "0";
    });
  }

  Widget generateBody(BuildContext context) {
    GridBoundsList boundsList =
        GridBoundsList([
      GridBounds(0, 0, 1, 4),
      GridBounds(1, 0, 1, 1),
      GridBounds(1, 1, 1, 1),
      GridBounds(1, 2, 1, 1),
      GridBounds(1, 3, 1, 1),
      GridBounds(2, 0, 1, 1),
      GridBounds(2, 1, 1, 1),
      GridBounds(2, 2, 1, 1),
      GridBounds(2, 3, 1, 1),
      GridBounds(3, 0, 1, 1),
      GridBounds(3, 1, 1, 1),
      GridBounds(3, 2, 1, 1),
      GridBounds(3, 3, 1, 1),
      GridBounds(4, 0, 1, 1),
      GridBounds(4, 1, 1, 2),
      GridBounds(4, 3, 2, 1),
      GridBounds(5, 0, 1, 1),
      GridBounds(5, 1, 1, 1),
      GridBounds(5, 2, 1, 1),
    ]);

    EdgeInsets padding = EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0);
    List<Widget> children = [
      Container(
        child: Text(displayNumber,
          style: TextStyle(
            fontSize: 50.0,
            textBaseline: TextBaseline.alphabetic,
          ),
          textAlign: TextAlign.right,
        ),
        padding: padding,
        margin: padding,
        alignment: Alignment.centerRight,
        color: Colors.grey[300],
      ),
      Padding(
        child: OperandButton(
          number: 7,
          caption: "7",
          onPressed: this.operandClicked,
        ),
        padding: padding,
      ),
      Padding(
        child: OperandButton(
          number: 8,
          caption: "8",
          onPressed: this.operandClicked,
        ),
        padding: padding,
      ),
      Padding(
        child: OperandButton(
          number: 9,
          caption: "9",
          onPressed: this.operandClicked,
        ),
        padding: padding,
      ),
      Padding(
        child: OperatorButton(
          identifier: OPERATOR_IDENTIFIER.DIVIDE,
          caption: "/",
          onPressed: this.operatorClicked,
        ),
        padding: padding,
      ),
      Padding(
        child: OperandButton(
          number: 4,
          caption: "4",
          onPressed: this.operandClicked,
        ),
        padding: padding,
      ),
      Padding(
        child: OperandButton(
          number: 5,
          caption: "5",
          onPressed: this.operandClicked,
        ),
        padding: padding,
      ),
      Padding(
        child: OperandButton(
          number: 6,
          caption: "6",
          onPressed: this.operandClicked,
        ),
        padding: padding,
      ),
      Padding(
        child: OperatorButton(
          identifier: OPERATOR_IDENTIFIER.MULTIPLY,
          caption: "x",
          onPressed: this.operatorClicked,
        ),
        padding: padding,
      ),
      Padding(
        child: OperandButton(
          number: 1,
          caption: "1",
          onPressed: this.operandClicked,
        ),
        padding: padding,
      ),
      Padding(
        child: OperandButton(
          number: 2,
          caption: "2",
          onPressed: this.operandClicked,
        ),
        padding: padding,
      ),
      Padding(
        child: OperandButton(
          number: 3,
          caption: "3",
          onPressed: this.operandClicked,
        ),
        padding: padding,
      ),
      Padding(
        child: OperatorButton(
          identifier: OPERATOR_IDENTIFIER.SUBTRACT,
          caption: "-",
          onPressed: this.operatorClicked,
        ),
        padding: padding,
      ),
      Padding(
        child: OperandButton(
          number: 10,
          caption: "0",
          onPressed: this.operandClicked,
        ),
        padding: padding,
      ),
      Padding(
        child: OperandButton(
          number: 100,
          caption: "00",
          onPressed: this.operandClicked,
        ),
        padding: padding,
      ),
      Padding(
        child: OperatorButton(
          identifier: OPERATOR_IDENTIFIER.PLUS,
          caption: "+",
          onPressed: this.operatorClicked,
        ),
        padding: padding,
      ),
      Padding(
        child: FlatButton(
          child: new Text(
            "AC",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40.0,
                color: Color.fromARGB(255, 255, 0, 0)),
          ),
          color: Color.fromARGB(255, 45, 120, 220),
          onPressed: this.allClear,
        ),
        padding: padding,
      ),
      Padding(
        child: FlatButton(
          child: new Text(
            "C",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40.0,
                color: Color.fromARGB(255, 255, 255, 255)),
          ),
          color: Color.fromARGB(255, 45, 120, 220),
          onPressed: this.currentClear,
        ),
        padding: padding,
      ),
      Padding(
        child: OperatorButton(
          identifier: OPERATOR_IDENTIFIER.NONE,
          caption: "=",
          onPressed: this.operatorClicked,
        ),
        padding: padding,
      ),
    ];

    return BoundsGridView(
      boundsList: boundsList,
      children: children,
      childAspectRatio: 1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("Flutterで作る電卓")),
      body: this.generateBody(context),
    );
  }
}

@immutable
class OperandButton extends FlatButton {
  OperandButton({
    @required this.caption,
    @required this.number,
    @required Function onPressed,
  }) :  assert(caption != null && caption != ""),
        assert(number != null),
        super(
          child: Text(
            caption,
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 40.0,
              color: Color.fromARGB(255, 255, 255, 255)
            ),
          ),
          onPressed: (){
            onPressed(number);
          },
        );

  final String caption;
  final int number;
  final Color color = Color.fromARGB(255, 45, 120, 220);
}

@immutable
class OperatorButton extends FlatButton {
  OperatorButton({
    @required this.caption,
    @required this.identifier,
    @required Function onPressed,
    ShapeBorder shape,
  }) :  assert(caption != null && caption != ""),
        assert(identifier != null),
        super(
        child: Text(
          caption,
          textDirection: TextDirection.ltr,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 40.0,
              color: Color.fromARGB(255, 255, 255, 255)
          ),
        ),
        onPressed: () {
          onPressed(identifier);
        },
        shape: shape,
      );
  final String caption;
  final OPERATOR_IDENTIFIER identifier;
  final Color color = Color.fromARGB(255, 45, 120, 220);
}
