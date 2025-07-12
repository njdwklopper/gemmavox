import 'dart:ui';
import 'package:flutter/material.dart';

class HomeButton {
  final String route;
  final String assetName;

  const HomeButton({
    required this.route,
    required this.assetName,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<HomeButton> homeButtons = const [
      HomeButton(route: '/voice_translator', assetName: 'basic_translator.png'),
      HomeButton(
          route: '/conversation_translator',
          assetName: 'conversation_translator.png'),
      HomeButton(route: '/image_translator', assetName: 'image_translate.png'),
      HomeButton(route: '/saved_items', assetName: 'histroy.png'),
    ];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Image.asset(
                    'assets/icons/logo.png',
                    fit: BoxFit.fitWidth,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    mainAxisSpacing: 7,
                    crossAxisSpacing: 7,
                    children: [
                      ...homeButtons
                          .map((button) => _imageButton(context, button))
                      // spacer to prevent overlap with bottom buttons
                    ],
                  ),
                ),
                // Bottom left button as a fixed-size square
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _bottomButton(context, '⚙️', '/help'),
                      _bottomButton(context, '?', '/settings')
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageButton(BuildContext context, HomeButton button) {
    final size = 230.0;
    bool _isTapped = false;

    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: StatefulBuilder(
        builder: (context, setState) {

          return GestureDetector(
            onTapDown: (_) => setState(() => _isTapped = true),
            onTapUp: (_) {
              setState(() => _isTapped = false);
              Navigator.pushReplacementNamed(context, button.route);
            },
            onTapCancel: () => setState(() => _isTapped = false),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 120),
              scale: _isTapped ? 0.92 : 1.0,
              curve: Curves.easeInOut,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Transform.translate(
                        offset: const Offset(4, 6),
                        child: Transform.scale(
                          scale: 1.05,
                          child: Image.asset(
                            'assets/icons/${button.assetName}',
                            height: size + 13,
                            fit: BoxFit.contain,
                            color: Colors.black.withOpacity(0.3),
                            colorBlendMode: BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/icons/${button.assetName}',
                    height: size,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Padding _bottomButton(BuildContext context, String icon, String route) {
    final ButtonStyle smallButtonStyle = IconButton.styleFrom(
      backgroundColor: Colors.grey[300],
      foregroundColor: Colors.black,
      padding: const EdgeInsets.all(8),
      iconSize: 42,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: 72,
        height: 72,
        child: IconButton(
          style: smallButtonStyle,
          icon: Text(icon, style: TextStyle(fontSize: 30)),
          onPressed: () {
            Navigator.pushReplacementNamed(context, route);
          },
        ),
      ),
    );
  }
}
