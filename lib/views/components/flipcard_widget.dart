import 'package:flutter/material.dart';

class FlipcardWidget extends StatefulWidget {
  const FlipcardWidget({super.key, required this.front, required this.back});

  final String front;
  final String back;

  @override
  State<FlipcardWidget> createState() => _FlipcardWidgetState();
}

class _FlipcardWidgetState extends State<FlipcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();

    // initialize the animation controller with duration of 600 milliseconds
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // define the animation with a smooth curve
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  // turn the flashcard to the front side or the back side
  void _toggleCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // dispose the animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: GestureDetector(
          onTap: _toggleCard,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.rotationY(_animation.value * 3.14159),
                alignment: Alignment.center,
                child: _animation.value < 0.5
                    ? _buildFrontCard()
                    : Transform.scale(
                        scaleX: -1,
                        scaleY: 1,
                        child: _buildBackCard(),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        width: double.infinity,
        height: 500,
        decoration: BoxDecoration(
          color: Colors.pinkAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.front,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBackCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        width: double.infinity,
        height: 500,
        decoration: BoxDecoration(
          color: Colors.pink[50],
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            widget.back,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
