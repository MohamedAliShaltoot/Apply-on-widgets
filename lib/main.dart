// import 'package:flutter/material.dart';
// import 'package:flutter_application_2/new_project/features/home_screen/views/home_view.dart';
// import 'package:flutter_application_2/screens/home_2.dart';
// import 'package:flutter_application_2/screens/test_home.dart';

// import 'widgets/home_screen.dart';

// //import 'package:flutter_application_2/db/db_helper.dart';

// void main() async {
//   //DbHelper helper = DbHelper();
// // DbHelper.helper.getPath();

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'Flutter Demo',
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//           useMaterial3: true,
//         ),
//         // home:  HomeScreen(),
//         // ignore: prefer_const_constructors
//         home: HomeView()

//         //const TextFormFieldWidget (),

//         );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui; // Explicitly import dart:ui with alias for clarity

void main() {
  runApp(const MyDrawingApp());
}

// ===========================================================================
// DATA MODELS & ENUMS
// ===========================================================================

// Expanded BackgroundType options
enum BackgroundType {
  none,
  grid, // Square grid
  dotted,
  lines, // Horizontal lines
  diagonal, // 45-degree lines
  isometric, // Isometric grid
  graphPaper, // Finer grid with bolder major lines
}

enum ToolType { pencil, eraser, line, rectangle, circle, text }

class DrawnObject {
  final List<Offset?>
      points; // Points defining the drawing (e.g., path for pencil, start/end for shapes)
  final Color color;
  final double width;
  final ToolType tool;
  final String? text; // For text tool
  final Color? backgroundColor; // Needed for eraser blend mode

  // For text rendering optimization
  TextPainter? _textPainter;

  DrawnObject({
    required this.points,
    required this.color,
    required this.width,
    required this.tool,
    this.text,
    this.backgroundColor,
  }) {
    if (tool == ToolType.text &&
        text != null &&
        points.isNotEmpty &&
        points[0] != null) {
      _initTextPainter();
    }
  }

  // Initialize TextPainter once
  void _initTextPainter() {
    _textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: width * 2 < 16 ? 16 : width * 2, // Min font size
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    _textPainter!.layout(); // Layout text immediately
  }

  // Get the initialized TextPainter
  TextPainter? get textPainter => _textPainter;

  // Helper for erasing functionality
  bool get isErasing => tool == ToolType.eraser;
}

// ===========================================================================
// MAIN APP WIDGET
// ===========================================================================

class MyDrawingApp extends StatefulWidget {
  const MyDrawingApp({super.key});

  @override
  State<MyDrawingApp> createState() => _MyDrawingAppState();
}

class _MyDrawingAppState extends State<MyDrawingApp> {
  bool _isDark = false;

  void _toggleTheme() {
    setState(() {
      _isDark = !_isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: DrawingPage(
        onToggleTheme: _toggleTheme,
        isDark: _isDark,
      ),
    );
  }
}

// ===========================================================================
// DRAWING PAGE WIDGET
// ===========================================================================

class DrawingPage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const DrawingPage(
      {super.key, required this.onToggleTheme, required this.isDark});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  List<DrawnObject> completedObjects = [];
  DrawnObject? currentDrawing;
  Offset? shapeStartPoint;

  Color selectedColor = Colors.black;
  double strokeWidth = 4.0;
  BackgroundType backgroundType = BackgroundType.none;
  ToolType selectedTool = ToolType.pencil;

  bool showControls = true;

  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  // Expanded Color Palette
  final List<Color> paletteColors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.teal,
    Colors.indigo,
    Colors.cyan,
    Colors.amber,
    Colors.grey,
    Colors.lime,
    Colors.deepOrange,
    Colors.lightBlue,
    Colors.deepPurpleAccent,
    Colors.greenAccent,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.pinkAccent,
    Colors.limeAccent,
    Colors.tealAccent,
  ];

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  // --- Gesture Handlers ---

  void _onPanStart(Offset position) {
    final effectiveColor =
        selectedTool == ToolType.eraser ? Colors.transparent : selectedColor;
    final effectiveWidth =
        selectedTool == ToolType.eraser ? strokeWidth * 1.5 : strokeWidth;

    if (selectedTool == ToolType.pencil || selectedTool == ToolType.eraser) {
      setState(() {
        currentDrawing = DrawnObject(
          points: [position],
          color: effectiveColor,
          width: effectiveWidth,
          tool: selectedTool,
          backgroundColor: widget.isDark ? Colors.black : Colors.white,
        );
      });
    } else {
      shapeStartPoint = position;
    }
  }

  void _onPanUpdate(Offset position) {
    if (currentDrawing != null &&
        (selectedTool == ToolType.pencil || selectedTool == ToolType.eraser)) {
      setState(() {
        currentDrawing!.points.add(position);
      });
    }
  }

  void _onPanEnd(Offset position) {
    if (selectedTool == ToolType.pencil || selectedTool == ToolType.eraser) {
      if (currentDrawing != null) {
        setState(() {
          completedObjects.add(currentDrawing!);
          currentDrawing = null;
        });
      }
    } else if (shapeStartPoint != null) {
      final List<Offset?> points = [shapeStartPoint!, position];
      setState(() {
        completedObjects.add(DrawnObject(
          points: points,
          color: selectedColor,
          width: strokeWidth,
          tool: selectedTool,
        ));
        shapeStartPoint = null;
      });
    }
    currentDrawing = null;
    shapeStartPoint = null;
  }

  void _onTapDown(Offset position) {
    if (selectedTool == ToolType.text) {
      shapeStartPoint = position;
    }
  }

  void _onTapUp(Offset position) {
    if (selectedTool == ToolType.text && shapeStartPoint != null) {
      _showTextInputDialog(shapeStartPoint!);
      shapeStartPoint = null;
    }
  }

  // --- UI Action Methods ---

  void _showTextInputDialog(Offset position) async {
    _textController.clear();
    final String? text = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Text'),
          content: TextField(
            controller: _textController,
            focusNode: _textFocusNode,
            decoration: const InputDecoration(hintText: "Type here"),
            autofocus: true,
            maxLines: null,
            textCapitalization: TextCapitalization
                .sentences, // Capitalize first letter of sentences
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                Navigator.pop(context, _textController.text);
              },
            ),
          ],
        );
      },
    );

    if (text != null && text.isNotEmpty) {
      setState(() {
        completedObjects.add(DrawnObject(
          points: [position],
          color: selectedColor,
          width: strokeWidth,
          tool: ToolType.text,
          text: text,
        ));
      });
    }
    _textFocusNode.unfocus();
  }

  void _undo() {
    if (completedObjects.isNotEmpty) {
      setState(() {
        completedObjects.removeLast();
      });
    }
  }

  void _clearCanvas() {
    setState(() {
      completedObjects.clear();
      currentDrawing = null;
      shapeStartPoint = null;
    });
  }

  // --- UI Builders ---

  Widget _buildPalette() => SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: paletteColors.length,
          itemBuilder: (context, index) => GestureDetector(
            onTap: () {
              setState(() {
                selectedColor = paletteColors[index];
                selectedTool = ToolType.pencil;
              });
            },
            child: Container(
              width: 32,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: paletteColors[index],
                shape: BoxShape.circle,
                border: Border.all(
                  color: selectedColor == paletteColors[index] &&
                          selectedTool == ToolType.pencil
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.4),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildBackgroundDropdown() => DropdownButton<BackgroundType>(
        value: backgroundType,
        onChanged: (value) {
          if (value != null) {
            setState(() => backgroundType = value);
          }
        },
        items: BackgroundType.values.map((bg) {
          Icon icon;
          String text;
          switch (bg) {
            case BackgroundType.none:
              icon = const Icon(Icons.close);
              text = "None";
              break;
            case BackgroundType.grid:
              icon = const Icon(Icons.grid_on);
              text = "Square Grid";
              break;
            case BackgroundType.dotted:
              icon = const Icon(Icons.blur_on);
              text = "Dotted";
              break;
            case BackgroundType.lines:
              icon = const Icon(Icons.line_weight);
              text = "Horizontal Lines";
              break;
            case BackgroundType.diagonal:
              icon =
                  const Icon(Icons.timeline); // More suitable icon for diagonal
              text = "Diagonal Lines";
              break;
            case BackgroundType.isometric:
              icon = const Icon(Icons.threed_rotation); // Simple 3D icon
              text = "Isometric Grid";
              break;
            case BackgroundType.graphPaper:
              icon = const Icon(
                  Icons.insert_chart_outlined); // Icon resembling chart lines
              text = "Graph Paper";
              break;
          }
          return DropdownMenuItem(
            value: bg,
            child: Row(
              children: [icon, const SizedBox(width: 8), Text(text)],
            ),
          );
        }).toList(),
      );

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? Colors.black : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Drawing App'),
        actions: [
          IconButton(
              onPressed: _undo,
              icon: const Icon(Icons.undo),
              tooltip: 'Undo Last Action'),
          IconButton(
              onPressed: _clearCanvas,
              icon: const Icon(Icons.delete),
              tooltip: 'Clear Canvas'),
          IconButton(
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: Icon(showControls ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                showControls = !showControls;
              });
            },
            tooltip: showControls ? 'Hide Controls' : 'Show Controls',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Builder(
              builder: (canvasContext) => GestureDetector(
                onPanStart: (details) => _onPanStart(
                    (canvasContext.findRenderObject() as RenderBox)
                        .globalToLocal(details.globalPosition)),
                onPanUpdate: (details) => _onPanUpdate(
                    (canvasContext.findRenderObject() as RenderBox)
                        .globalToLocal(details.globalPosition)),
                onPanEnd: (details) => _onPanEnd(
                    (canvasContext.findRenderObject() as RenderBox)
                        .globalToLocal(details.globalPosition)),
                onTapDown: (details) => _onTapDown(
                    (canvasContext.findRenderObject() as RenderBox)
                        .globalToLocal(details.globalPosition)),
                onTapUp: (details) => _onTapUp(
                    (canvasContext.findRenderObject() as RenderBox)
                        .globalToLocal(details.globalPosition)),
                child: CustomPaint(
                  painter: DrawingPainter(
                    completedObjects,
                    currentDrawing,
                    backgroundType,
                    bgColor,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
          if (showControls) ...[
            const Divider(height: 1),
            Container(
              color: Theme.of(context).canvasColor,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                children: [
                  _buildPalette(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ToolType.values
                        .map((tool) => Expanded(
                              child: IconButton(
                                icon: Icon(
                                  tool == ToolType.pencil
                                      ? Icons.brush
                                      : tool == ToolType.eraser
                                          ? Icons.cleaning_services
                                          : tool == ToolType.line
                                              ? Icons.line_weight
                                              : tool == ToolType.rectangle
                                                  ? Icons.rectangle_outlined
                                                  : tool == ToolType.circle
                                                      ? Icons.circle_outlined
                                                      : Icons.text_fields,
                                  color: selectedTool == tool
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedTool = tool;
                                  });
                                },
                                tooltip: tool.name.capitalize(),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.line_weight),
                      Expanded(
                        child: Slider(
                          min: 1,
                          max: 20,
                          value: strokeWidth,
                          onChanged: (value) {
                            setState(() => strokeWidth = value);
                          },
                        ),
                      ),
                      Text(strokeWidth.toStringAsFixed(1)),
                      const SizedBox(width: 16),
                      const Text("Background: "),
                      _buildBackgroundDropdown(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ===========================================================================
// CUSTOM PAINTER
// ===========================================================================

class DrawingPainter extends CustomPainter {
  final List<DrawnObject> completedObjects;
  final DrawnObject? currentDrawing;
  final BackgroundType backgroundType;
  final Color backgroundColor;

  DrawingPainter(
    this.completedObjects,
    this.currentDrawing,
    this.backgroundType,
    this.backgroundColor,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    _drawBackgroundGrid(canvas, size);

    for (final obj in completedObjects) {
      _drawObject(canvas, obj);
    }
    if (currentDrawing != null) {
      _drawObject(canvas, currentDrawing!);
    }
  }

  void _drawObject(Canvas canvas, DrawnObject obj) {
    final paint = Paint()
      ..color = obj.color
      ..strokeWidth = obj.width
      ..strokeCap = StrokeCap.round
      ..blendMode = obj.isErasing ? BlendMode.clear : BlendMode.srcOver
      ..style = (obj.tool == ToolType.rectangle ||
              obj.tool == ToolType.circle ||
              obj.tool == ToolType.line)
          ? PaintingStyle.stroke
          : PaintingStyle.stroke;

    switch (obj.tool) {
      case ToolType.pencil:
      case ToolType.eraser:
        for (int i = 0; i < obj.points.length - 1; i++) {
          if (obj.points[i] != null && obj.points[i + 1] != null) {
            canvas.drawLine(obj.points[i]!, obj.points[i + 1]!, paint);
          }
        }
        break;
      case ToolType.line:
        if (obj.points.length >= 2 &&
            obj.points[0] != null &&
            obj.points[1] != null) {
          canvas.drawLine(obj.points[0]!, obj.points[1]!, paint);
        }
        break;
      case ToolType.rectangle:
        if (obj.points.length >= 2 &&
            obj.points[0] != null &&
            obj.points[1] != null) {
          final rect = Rect.fromPoints(obj.points[0]!, obj.points[1]!);
          canvas.drawRect(rect, paint);
        }
        break;
      case ToolType.circle:
        if (obj.points.length >= 2 &&
            obj.points[0] != null &&
            obj.points[1] != null) {
          final center = (obj.points[0]! + obj.points[1]!) / 2;
          final radius = (obj.points[0]! - obj.points[1]!).distance / 2;
          canvas.drawCircle(center, radius, paint);
        }
        break;
      case ToolType.text:
        if (obj.textPainter != null &&
            obj.points.isNotEmpty &&
            obj.points[0] != null) {
          obj.textPainter!.paint(canvas, obj.points[0]!);
        }
        break;
    }
  }

  void _drawBackgroundGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    const spacing = 20.0;
    const majorSpacing = 100.0; // For graph paper

    switch (backgroundType) {
      case BackgroundType.grid:
        for (double x = 0; x <= size.width; x += spacing) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        }
        for (double y = 0; y <= size.height; y += spacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        break;
      case BackgroundType.dotted:
        for (double x = 0; x <= size.width; x += spacing) {
          for (double y = 0; y <= size.height; y += spacing) {
            canvas.drawCircle(Offset(x, y), 1.5, paint);
          }
        }
        break;
      case BackgroundType.lines:
        for (double y = 0; y <= size.height; y += spacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        break;
      case BackgroundType.diagonal:
        // Draw diagonal lines from bottom-left to top-right
        for (double x = -size.height; x <= size.width; x += spacing) {
          canvas.drawLine(
              Offset(x, size.height), Offset(x + size.height, 0), paint);
        }
        // Draw diagonal lines from top-left to bottom-right
        for (double x = -size.height; x <= size.width; x += spacing) {
          canvas.drawLine(
              Offset(x, 0), Offset(x + size.height, size.height), paint);
        }
        break;
      case BackgroundType.isometric:
        // Horizontal lines
        for (double y = 0; y <= size.height; y += spacing * 0.866) {
          // sin(60)
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        // Diagonal lines (30 degrees)
        for (double x = -size.height / 0.577;
            x <= size.width + size.height / 0.577;
            x += spacing / 0.577) {
          // tan(30)
          canvas.drawLine(Offset(x, 0),
              Offset(x + size.height / 0.577, size.height), paint);
          canvas.drawLine(Offset(x, size.height),
              Offset(x + size.height / 0.577, 0), paint);
        }
        break;
      case BackgroundType.graphPaper:
        // Minor grid lines
        for (double x = 0; x <= size.width; x += spacing) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        }
        for (double y = 0; y <= size.height; y += spacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        // Major grid lines
        final majorPaint = Paint()
          ..color = Colors.grey.withOpacity(0.5)
          ..strokeWidth = 1.5;
        for (double x = 0; x <= size.width; x += majorSpacing) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), majorPaint);
        }
        for (double y = 0; y <= size.height; y += majorSpacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), majorPaint);
        }
        break;
      case BackgroundType.none:
        break;
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    if (oldDelegate.backgroundType != backgroundType ||
        oldDelegate.backgroundColor != backgroundColor) {
      return true;
    }
    if (oldDelegate.completedObjects.length != completedObjects.length) {
      return true;
    }
    if (currentDrawing != oldDelegate.currentDrawing) {
      return true;
    }
    if (currentDrawing != null &&
        oldDelegate.currentDrawing != null &&
        currentDrawing!.points.length !=
            oldDelegate.currentDrawing!.points.length) {
      return true;
    }
    return false;
  }
}

// ===========================================================================
// UTILITY EXTENSIONS
// ===========================================================================

extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
