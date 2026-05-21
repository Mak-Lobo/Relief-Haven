import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary.withValues(alpha: 0.5),
        title: Shimmer.fromColors(
          baseColor: colors.surfaceContainerHigh,
          highlightColor: colors.surfaceContainerLow,
          child: Container(
            width: 150,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ShimmerBox(
                height: 50,
                width: double.infinity,
                borderRadius: 25,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ShimmerBox(
                height: 350,
                width: double.infinity,
                borderRadius: 20,
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ShimmerBox(
                height: 200,
                width: double.infinity,
                borderRadius: 34,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.height,
    required this.width,
    this.borderRadius = 8,
  });

  final double height;
  final double width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colors.surfaceContainerLow,
      highlightColor: colors.surfaceContainerHigh,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class MapShimmer extends StatelessWidget {
  const MapShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerBox(
      height: double.infinity,
      width: double.infinity,
      borderRadius: 0,
    );
  }
}

class DonationHistoryShimmer extends StatelessWidget {
  const DonationHistoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: ShimmerBox(
            height: 100,
            width: double.infinity,
            borderRadius: 18,
          ),
        ),
      ),
    );
  }
}

class ChatShimmer extends StatelessWidget {
  const ChatShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 5,
      itemBuilder: (context, index) {
        final isUser = index % 2 == 0;
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ShimmerBox(
              height: 60,
              width: MediaQuery.of(context).size.width * 0.6,
              borderRadius: 15,
            ),
          ),
        );
      },
    );
  }
}

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ShimmerBox(height: 500, width: double.infinity, borderRadius: 34),
    );
  }
}

class ChatResponseLoadingShimmer extends StatelessWidget {
  const ChatResponseLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(
              height: 18,
              width: MediaQuery.of(context).size.width * 0.7,
              borderRadius: 9,
            ),
            const SizedBox(height: 8),
            ShimmerBox(
              height: 18,
              width: MediaQuery.of(context).size.width * 0.6,
              borderRadius: 9,
            ),
            const SizedBox(height: 8),
            ShimmerBox(
              height: 18,
              width: MediaQuery.of(context).size.width * 0.4,
              borderRadius: 9,
            ),
          ],
        ),
      ),
    );
  }
}
