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
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // For RepaintBoundary
import 'dart:ui' as ui; // Explicitly import dart:ui with alias for clarity
import 'dart:io'; // For file operations
import 'dart:convert'; // For JSON encoding/decoding

import 'package:path_provider/path_provider.dart'; // For getting app directories
import 'package:image/image.dart' as img; // For image encoding
import 'package:image_gallery_saver/image_gallery_saver.dart'; // For saving to gallery
import 'package:permission_handler/permission_handler.dart'; // For permissions

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
  final List<Offset?> points;
  final Color color;
  final double width;
  final ToolType tool;
  final String? text;
  final Color? backgroundColor; // Needed for eraser blend mode

  // For text rendering optimization - cached TextPainter
  late final TextPainter _textPainter; // Marked as late final

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
      _textPainter.layout(); // Layout text immediately when created
    }
  }

  // Get the initialized TextPainter (nullable for non-text objects)
  TextPainter? get textPainter =>
      (tool == ToolType.text && text != null) ? _textPainter : null;

  // Helper for erasing functionality
  bool get isErasing => tool == ToolType.eraser;

  // --- Serialization Methods ---
  factory DrawnObject.fromJson(Map<String, dynamic> json) {
    // Deserialize points
    List<Offset?> points = (json['points'] as List)
        .map((p) =>
            p == null ? null : Offset(p['dx'] as double, p['dy'] as double))
        .toList();

    // Deserialize color (from int)
    Color color = Color(json['color'] as int);

    // Deserialize tool (from string)
    ToolType tool = ToolType.values
        .firstWhere((e) => e.toString() == 'ToolType.${json['tool']}');

    // Deserialize background color (nullable int)
    Color? backgroundColor = json['backgroundColor'] != null
        ? Color(json['backgroundColor'] as int)
        : null;

    return DrawnObject(
      points: points,
      color: color,
      width: json['width'] as double,
      tool: tool,
      text: json['text'] as String?,
      backgroundColor: backgroundColor,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'points': points
          .map((p) => p == null ? null : {'dx': p.dx, 'dy': p.dy})
          .toList(),
      'color': color.value, // Store Color as int
      'width': width,
      'tool': tool.toString().split('.').last, // Store enum as String
      'text': text,
      'backgroundColor':
          backgroundColor?.value, // Store Color as int (nullable)
    };
  }
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
  // Undo/Redo Stacks
  List<List<DrawnObject>> _undoStack = [];
  List<List<DrawnObject>> _redoStack = [];
  final int _maxUndoRedoStates = 50; // Limit memory usage

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

  // GlobalKey for capturing the CustomPaint as an image
  final GlobalKey _repaintBoundaryKey = GlobalKey();

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
  void initState() {
    super.initState();
    _saveStateForUndo(); // Save initial empty state for undo
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  // --- Undo/Redo Logic ---

  void _saveStateForUndo() {
    // Only save if the state has actually changed from the last saved state
    if (_undoStack.isNotEmpty &&
        _listEquals(completedObjects, _undoStack.last)) {
      return; // State hasn't changed, no need to save
    }

    _undoStack.add(List.from(completedObjects)); // Deep copy the list
    if (_undoStack.length > _maxUndoRedoStates) {
      _undoStack.removeAt(0); // Remove the oldest state
    }
    _redoStack.clear(); // Any new action clears the redo stack
  }

  bool _listEquals(List<DrawnObject> a, List<DrawnObject> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      // For simplicity, we just compare references.
      // A more robust equality check would compare content of DrawnObject.
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _undo() {
    if (_undoStack.length > 1) {
      setState(() {
        _redoStack.add(_undoStack.removeLast()); // Move current state to redo
        completedObjects =
            List.from(_undoStack.last); // Revert to previous state
        currentDrawing = null; // Clear any active drawing
        shapeStartPoint = null;
      });
    } else {
      _showSnackbar('Nothing to undo.');
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      setState(() {
        final stateToRedo = _redoStack.removeLast();
        _undoStack.add(stateToRedo);
        completedObjects = List.from(stateToRedo);
        currentDrawing = null;
        shapeStartPoint = null;
      });
    } else {
      _showSnackbar('Nothing to redo.');
    }
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
        _saveStateForUndo(); // Save state after a continuous drawing is finished
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
      _saveStateForUndo(); // Save state after a shape is finished
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
      // _saveStateForUndo() called after text is added in _showTextInputDialog's setState
    }
    shapeStartPoint = null;
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
            textCapitalization: TextCapitalization.sentences,
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
      _saveStateForUndo(); // Save state after text is added
    }
    _textFocusNode.unfocus();
  }

  void _clearCanvas() {
    if (completedObjects.isNotEmpty) {
      setState(() {
        completedObjects.clear();
        currentDrawing = null;
        shapeStartPoint = null;
      });
      _saveStateForUndo(); // Save state after clearing canvas
    } else {
      _showSnackbar('Canvas is already empty.');
    }
  }

  // --- Save/Load/Export Methods ---

  Future<String?> _getDrawingsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final drawingsDir = Directory('${directory.path}/drawings');
    if (!await drawingsDir.exists()) {
      await drawingsDir.create(recursive: true);
    }
    return drawingsDir.path;
  }

  Future<void> _saveDrawing() async {
    String? dirPath = await _getDrawingsDirectory();
    if (dirPath == null) {
      _showSnackbar('Could not find directory to save.');
      return;
    }

    String? filename = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController filenameController = TextEditingController();
        return AlertDialog(
          title: const Text('Save Drawing'),
          content: TextField(
            controller: filenameController,
            decoration: const InputDecoration(
                hintText: 'Enter filename (e.g., my_drawing)'),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                Navigator.pop(context, filenameController.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (filename != null && filename.isNotEmpty) {
      try {
        final file = File('$dirPath/$filename.json');
        List<Map<String, dynamic>> jsonList =
            completedObjects.map((obj) => obj.toJson()).toList();
        await file.writeAsString(jsonEncode(jsonList));
        _showSnackbar('Drawing "$filename" saved successfully!');
      } catch (e) {
        _showSnackbar('Error saving drawing: $e');
      }
    }
  }

  Future<void> _loadDrawing() async {
    String? dirPath = await _getDrawingsDirectory();
    if (dirPath == null) {
      _showSnackbar('Could not find directory to load from.');
      return;
    }

    try {
      final directory = Directory(dirPath);
      final List<FileSystemEntity> files = directory.listSync().toList();
      final List<String> drawingFiles = files
          .where((file) => file.path.endsWith('.json'))
          .map((file) => file.path
              .split(Platform.pathSeparator)
              .last
              .replaceAll('.json', ''))
          .toList();

      if (drawingFiles.isEmpty) {
        _showSnackbar('No saved drawings found.');
        return;
      }

      String? selectedFilename = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Load Drawing'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: drawingFiles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(drawingFiles[index]),
                    onTap: () => Navigator.pop(context, drawingFiles[index]),
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
            ],
          );
        },
      );

      if (selectedFilename != null && selectedFilename.isNotEmpty) {
        final file = File('$dirPath/$selectedFilename.json');
        String jsonString = await file.readAsString();
        List<dynamic> jsonList = jsonDecode(jsonString);
        setState(() {
          completedObjects = jsonList
              .map((json) => DrawnObject.fromJson(json as Map<String, dynamic>))
              .toList();
          currentDrawing = null;
          shapeStartPoint = null;
          _saveStateForUndo(); // Save loaded state for undo
        });
        _showSnackbar('Drawing "$selectedFilename" loaded successfully!');
      }
    } catch (e) {
      _showSnackbar('Error loading drawing: $e');
    }
  }

  Future<void> _exportDrawingAsImage() async {
    // Request permissions
    var status = await Permission.storage.request();
    if (status != PermissionStatus.granted) {
      _showSnackbar('Storage permission not granted. Cannot save image.');
      openAppSettings(); // Open app settings if permission denied
      return;
    }

    try {
      RenderRepaintBoundary? boundary = _repaintBoundaryKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        _showSnackbar('Error: Could not find repaint boundary.');
        return;
      }

      ui.Image image = await boundary.toImage(
          pixelRatio: 3.0); // Higher pixelRatio for better quality
      ByteData? byteData =
          await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) {
        _showSnackbar('Error: Could not convert image to bytes.');
        return;
      }

      final result = await ImageGallerySaver.saveImage(
        byteData.buffer.asUint8List(),
        quality: 90,
        name: "DrawingApp_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (result['isSuccess']) {
        _showSnackbar('Image saved to gallery!');
      } else {
        _showSnackbar(
            'Error saving image: ${result['errorMessage'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _showSnackbar('Error exporting image: $e');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
              icon = const Icon(Icons.timeline);
              text = "Diagonal Lines";
              break;
            case BackgroundType.isometric:
              icon = const Icon(Icons.threed_rotation);
              text = "Isometric Grid";
              break;
            case BackgroundType.graphPaper:
              icon = const Icon(Icons.insert_chart_outlined);
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
              onPressed: _redo,
              icon: const Icon(Icons.redo),
              tooltip: 'Redo Last Action'), // Redo button
          IconButton(
              onPressed: _clearCanvas,
              icon: const Icon(Icons.delete),
              tooltip: 'Clear Canvas'),
          IconButton(
              onPressed: _saveDrawing,
              icon: const Icon(Icons.save),
              tooltip: 'Save Drawing'),
          IconButton(
              onPressed: _loadDrawing,
              icon: const Icon(Icons.folder_open),
              tooltip: 'Load Drawing'),
          IconButton(
              onPressed: _exportDrawingAsImage,
              icon: const Icon(Icons.image),
              tooltip: 'Export as Image'),
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
            child: RepaintBoundary(
              // Wrap CustomPaint with RepaintBoundary for image export
              key: _repaintBoundaryKey,
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
        // Use the cached TextPainter
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
      ..color = const Color.fromARGB(255, 198, 9, 100).withOpacity(0.3)
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
        // Horizontal lines (30-degree up)
        for (double y = 0; y <= size.height; y += spacing * 0.866) {
          // sin(60) for vertical distance
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        // Diagonal lines (30 degrees from horizontal)
        for (double x = -size.height / 0.577;
            x <= size.width + size.height / 0.577;
            x += spacing / 0.577) {
          // tan(30) for spacing
          // Line 1: top-left to bottom-right
          canvas.drawLine(
              Offset(x, 0),
              Offset(x + size.height * 1.732, size.height),
              paint); // ~height * cot(30)
          // Line 2: bottom-left to top-right
          canvas.drawLine(Offset(x, size.height),
              Offset(x + size.height * 1.732, 0), paint);
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
    // Deep equality check for text changes to force repaint if text content changes (unlikely for existing objects)
    // For general changes in completedObjects, a reference comparison (via list equality) is sufficient if objects are immutable.
    // However, DrawnObject is mutable (its points list).
    // A full deep comparison can be costly, but the above length checks cover most cases.
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

