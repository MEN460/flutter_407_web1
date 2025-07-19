import 'package:flutter/material.dart';

/// A customizable star rating widget that displays and optionally allows
/// interaction with a 5-star rating system.
class RatingStars extends StatelessWidget {
  /// The current rating value (1-5). Values outside this range will be clamped.
  final int rating;

  /// Callback function called when a star is tapped.
  /// Receives the new rating value (1-5) as parameter.
  final void Function(int rating)? onRatingChanged;

  /// The size of each star icon. Defaults to 32.0.
  final double starSize;

  /// The color of filled (selected) stars. Defaults to Colors.amber.
  final Color filledColor;

  /// The color of empty (unselected) stars. Defaults to Colors.grey.
  final Color unfilledColor;

  /// The spacing between stars. Defaults to 4.0.
  final double spacing;

  /// Whether to show a visual indication when stars are interactive.
  /// Defaults to true when onRatingChanged is provided.
  final bool showInteractiveIndicator;

  const RatingStars({
    super.key,
    required this.rating,
    this.onRatingChanged,
    this.starSize = 32.0,
    this.filledColor = Colors.amber,
    this.unfilledColor = Colors.grey,
    this.spacing = 4.0,
    this.showInteractiveIndicator = true,
  });

  /// Whether this rating widget is interactive
  bool get isInteractive => onRatingChanged != null;

  /// Clamps the rating to valid range (1-5)
  int get _clampedRating => rating.clamp(0, 5);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Rating: $_clampedRating out of 5 stars',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          final starNumber = index + 1;
          final isFilled = index < _clampedRating;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: _buildStar(
              context,
              starNumber: starNumber,
              isFilled: isFilled,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStar(
    BuildContext context, {
    required int starNumber,
    required bool isFilled,
  }) {
    final star = Icon(
      isFilled ? Icons.star : Icons.star_border,
      color: isFilled ? filledColor : unfilledColor,
      size: starSize,
    );

    if (!isInteractive) {
      return star;
    }

    return GestureDetector(
      onTap: () => onRatingChanged!(starNumber),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(4.0),
          decoration: showInteractiveIndicator
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: Colors.transparent,
                )
              : null,
          child: Semantics(
            button: true,
            label: 'Rate $starNumber ${starNumber == 1 ? 'star' : 'stars'}',
            child: star,
          ),
        ),
      ),
    );
  }
}

/// Example usage widget demonstrating the RatingStars component
class RatingStarsExample extends StatefulWidget {
  const RatingStarsExample({super.key});

  @override
  State<RatingStarsExample> createState() => _RatingStarsExampleState();
}

class _RatingStarsExampleState extends State<RatingStarsExample> {
  int _currentRating = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rating Stars Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Interactive Rating:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            RatingStars(
              rating: _currentRating,
              onRatingChanged: (newRating) {
                setState(() {
                  _currentRating = newRating;
                });
              },
            ),
            const SizedBox(height: 16),
            Text('Current Rating: $_currentRating/5'),

            const SizedBox(height: 40),

            const Text('Read-only Rating:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            const RatingStars(
              rating: 4,
              filledColor: Colors.red,
              unfilledColor: Colors.grey,
              starSize: 40,
            ),

            const SizedBox(height: 40),

            const Text('Custom Styled Rating:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            RatingStars(
              rating: 2,
              onRatingChanged: (newRating) {
                setState(() {
                  _currentRating = newRating;
                });
              },
              filledColor: Colors.purple,
              unfilledColor: Colors.purple.withOpacity(0.3),
              starSize: 24,
              spacing: 8,
            ),
          ],
        ),
      ),
    );
  }
}
