import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Playful Poetry Generator',
      debugShowCheckedModeBanner: false,
      theme: FlexThemeData.light(
        scheme: FlexScheme.purpleBrown,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 9,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
          inputDecoratorRadius: 20.0,
          inputDecoratorUnfocusedHasBorder: false,
          fabRadius: 20.0,
          elevatedButtonRadius: 20.0,
          textButtonRadius: 20.0,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        fontFamily: GoogleFonts.comicNeue().fontFamily,
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.purpleBrown,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        fontFamily: GoogleFonts.comicNeue().fontFamily,
      ),
      themeMode: ThemeMode.system,
      home: const PoetryGeneratorPage(title: 'Playful Poetry Generator'),
    );
  }
}

class PoetryGeneratorPage extends StatefulWidget {
  const PoetryGeneratorPage({super.key, required this.title});

  final String title;

  @override
  State<PoetryGeneratorPage> createState() => _PoetryGeneratorPageState();
}

class _PoetryGeneratorPageState extends State<PoetryGeneratorPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _subjectController = TextEditingController();
  String _selectedPoetryType = 'Sonnet';
  final List<String> _poetryTypes = [
    'Sonnet',
    'Haiku',
    'Free Verse',
    'Limerick'
  ];
  String _generatedPoem = '';
  String _poemTitle = '';
  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _generatePoem() async {
    setState(() {
      _isLoading = true;
    });

    // Show loading animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: _animationController,
                child: const Icon(Icons.auto_awesome, size: 50),
              ),
              const SizedBox(height: 16),
              const Text('Brewing poetic magic...'),
            ],
          ),
        );
      },
    );

    try {
      var pocketbaseUrl = 'https://ai-poetry-generator.fly.dev';
      // var pocketbaseUrl = 'http://localhost:8090';
      var pb = PocketBase(pocketbaseUrl);

      var data = await pb.send(
        '/api/poetry',
        method: 'POST',
        body: {
          'subject': _subjectController.text,
          'type': _selectedPoetryType,
        },
      );

      setState(() {
        _generatedPoem = data['poem'];
        _poemTitle = data['title'];
        _isLoading = false;
      });

      // Close loading animation
      Navigator.of(context).pop();

      // Show poem in a new modal
      _showPoemModal();
    } catch (e) {
      setState(() {
        _generatedPoem = 'Oops! Our muse took a coffee break. Try again?';
        _isLoading = false;
      });

      // Close loading animation
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Poetry spirits are shy today. Give it another go!')),
      );
    }
  }

  void _showPoemModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _poemTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 600.ms).scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.easeOutQuad),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Text(
                        _generatedPoem,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(duration: 1000.ms, delay: 300.ms)
                          .slideY(
                              begin: 0.2,
                              end: 0,
                              duration: 800.ms,
                              delay: 300.ms,
                              curve: Curves.easeOutQuad),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Close this poetic masterpiece'),
                  ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 600.ms,
                      delay: 800.ms,
                      curve: Curves.easeOutQuad),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title)
            .animate()
            .fadeIn(duration: 600.ms, curve: Curves.easeOutQuad)
            .slideX(
                begin: -0.2,
                end: 0,
                duration: 600.ms,
                curve: Curves.easeOutQuad),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _subjectController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText:
                      'What shall we write about today?\nLove? Nature? Unicorns?',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 600.ms,
                  delay: 200.ms,
                  curve: Curves.easeOutQuad),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPoetryType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                items: _poetryTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPoetryType = newValue!;
                  });
                },
              ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 600.ms,
                  delay: 400.ms,
                  curve: Curves.easeOutQuad),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _generatePoem,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Summon the Muse!'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 600.ms).scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  delay: 600.ms,
                  curve: Curves.elasticOut),
            ],
          ),
        ),
      ),
    );
  }
}
