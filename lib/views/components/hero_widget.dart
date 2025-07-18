import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroWidget extends StatefulWidget {
  const HeroWidget({super.key, required this.title});

  final String title;

  @override
  State<HeroWidget> createState() => _HeroWidgetState();
}

class _HeroWidgetState extends State<HeroWidget> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "banner",
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(20),
            child: Image.asset("assets/images/banner.png"),
          ),
          Text(
            widget.title,
            style: GoogleFonts.baskervville(
              fontSize: 50,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
