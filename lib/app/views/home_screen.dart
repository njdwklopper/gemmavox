import 'package:flutter/material.dart';

class HomeButton {
  final String label;
  final String route;
  const HomeButton({required this.label, required this.route});
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final ButtonStyle bigButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(35),
      padding: EdgeInsets.zero,
      textStyle: const TextStyle(fontSize: 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
    );

    final ButtonStyle smallButtonStyle = IconButton.styleFrom(
      backgroundColor: Colors.grey[300],
      foregroundColor: Colors.black,
      padding: const EdgeInsets.all(8),
      iconSize: 36,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final List<HomeButton> homeButtons = const [
      HomeButton(label: '🗣️🇬🇧🇰🇷🇰🇭', route: '/voice_translator'),
      HomeButton(label: '🗣️<->🗣️', route: '/conversation_translator'),
      HomeButton(label: '📷🇬🇧🇰🇭🇰🇷', route: '/image_translator'),
      HomeButton(label: '🗂️', route: '/saved_items'),
    ];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            // Main content: column with image placeholder and 4 vertical buttons
            Column(
              children: [
                const SizedBox(height: 32),
                SizedBox(
                  height: 120,
                  child: Center(
                    child: Placeholder(), // Replace with Image.asset('assets/your_logo.png') later
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(homeButtons.length, (index) {
                        final button = homeButtons[index];
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: bigButtonStyle,
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, button.route);
                                },
                                child: Text(button.label),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
            // Bottom left button as a fixed-size square
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: IconButton(
                    style: smallButtonStyle,
                    icon: const Text('⚙️', style: TextStyle(fontSize: 30)),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/settings');
                    },
                  ),
                ),
              ),
            ),
            // Bottom right button as a fixed-size square
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: IconButton(
                    style: smallButtonStyle,
                    icon: const Text('?', style: TextStyle(fontSize: 30)),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/help');
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
