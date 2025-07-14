import 'package:flutter/material.dart';
import 'package:k_airways_flutter/utils/responsive_layout.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help Center')),
      body: ResponsiveLayout(
        mobile: _buildMobileView(),
        desktop: _buildDesktopView(),
      ),
    );
  }

  Widget _buildMobileView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFaqSection(),
        const SizedBox(height: 20),
        _buildSupportSection(),
        const SizedBox(height: 20),
        _buildTutorialSection(),
      ],
    );
  }

  Widget _buildDesktopView() {
    return Row(
      children: [
        Expanded(child: _buildFaqSection()),
        const VerticalDivider(),
        Expanded(child: _buildSupportSection()),
        const VerticalDivider(),
        Expanded(child: _buildTutorialSection()),
      ],
    );
  }

  Widget _buildFaqSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Frequently Asked Questions', style: TextStyle(fontSize: 18)),
        // FAQ items would go here
      ],
    );
  }

  Widget _buildSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Contact Support', style: TextStyle(fontSize: 18)),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Your Name'),
        ),
        TextFormField(decoration: const InputDecoration(labelText: 'Email')),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Message'),
          maxLines: 5,
        ),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: () {}, child: const Text('Submit Ticket')),
      ],
    );
  }

  Widget _buildTutorialSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Video Tutorials', style: TextStyle(fontSize: 18)),
        // Tutorial items would go here
      ],
    );
  }
}
