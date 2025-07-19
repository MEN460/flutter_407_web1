import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/utils/responsive_layout.dart';

// Models
class FaqItem {
  final String question;
  final String answer;
  final String category;

  const FaqItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}

class Tutorial {
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final Duration duration;

  const Tutorial({
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.duration,
  });
}

class SupportTicket {
  final String name;
  final String email;
  final String subject;
  final String message;
  final String priority;

  const SupportTicket({
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    required this.priority,
  });
}

// Sample data
const List<FaqItem> faqItems = [
  FaqItem(
    question: 'How do I cancel my booking?',
    answer:
        'You can cancel your booking by going to "My Bookings" and selecting the cancel option. Please note that cancellation fees may apply depending on your fare type.',
    category: 'Booking',
  ),
  FaqItem(
    question: 'Can I change my flight dates?',
    answer:
        'Yes, you can change your flight dates subject to availability and fare rules. Additional fees may apply for date changes.',
    category: 'Booking',
  ),
  FaqItem(
    question: 'What baggage allowance do I have?',
    answer:
        'Baggage allowance varies by fare type and destination. Economy class typically includes 23kg checked baggage and 7kg carry-on.',
    category: 'Baggage',
  ),
  FaqItem(
    question: 'How early should I arrive at the airport?',
    answer:
        'We recommend arriving 2 hours before domestic flights and 3 hours before international flights.',
    category: 'Travel',
  ),
  FaqItem(
    question: 'Can I select my seat in advance?',
    answer:
        'Yes, you can select your seat during booking or manage your reservation. Premium seat selection may incur additional charges.',
    category: 'Booking',
  ),
];

const List<Tutorial> tutorials = [
  Tutorial(
    title: 'How to Book a Flight',
    description: 'Step-by-step guide to booking your flight on our platform',
    thumbnailUrl: 'https://via.placeholder.com/300x200',
    videoUrl: 'https://example.com/booking-tutorial',
    duration: Duration(minutes: 3, seconds: 45),
  ),
  Tutorial(
    title: 'Managing Your Booking',
    description: 'Learn how to view, modify, or cancel your reservations',
    thumbnailUrl: 'https://via.placeholder.com/300x200',
    videoUrl: 'https://example.com/manage-booking',
    duration: Duration(minutes: 2, seconds: 30),
  ),
  Tutorial(
    title: 'Check-in Process',
    description: 'Complete guide to online check-in and mobile boarding passes',
    thumbnailUrl: 'https://via.placeholder.com/300x200',
    videoUrl: 'https://example.com/checkin-tutorial',
    duration: Duration(minutes: 4, seconds: 15),
  ),
];

// Support form provider
final supportFormProvider =
    StateNotifierProvider<SupportFormNotifier, SupportFormState>((ref) {
      return SupportFormNotifier();
    });

class SupportFormState {
  final bool isSubmitting;
  final bool isSubmitted;
  final String? error;

  const SupportFormState({
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.error,
  });

  SupportFormState copyWith({
    bool? isSubmitting,
    bool? isSubmitted,
    String? error,
  }) {
    return SupportFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      error: error,
    );
  }
}

class SupportFormNotifier extends StateNotifier<SupportFormState> {
  SupportFormNotifier() : super(const SupportFormState());

  Future<void> submitTicket(SupportTicket ticket) async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Here you would typically call your API
      // await supportService.submitTicket(ticket);

      state = state.copyWith(isSubmitting: false, isSubmitted: true);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to submit ticket. Please try again.',
      );
    }
  }

  void reset() {
    state = const SupportFormState();
  }
}

class HelpCenterScreen extends ConsumerStatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  ConsumerState<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends ConsumerState<HelpCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFaqCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.help), text: 'FAQ'),
            Tab(icon: Icon(Icons.support_agent), text: 'Support'),
            Tab(icon: Icon(Icons.play_circle), text: 'Tutorials'),
          ],
        ),
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileView(),
        desktop: _buildDesktopView(),
      ),
    );
  }

  Widget _buildMobileView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildFaqSection(),
        _buildSupportSection(),
        _buildTutorialSection(),
      ],
    );
  }

  Widget _buildDesktopView() {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildFaqSection()),
        const VerticalDivider(width: 1),
        Expanded(flex: 2, child: _buildSupportSection()),
        const VerticalDivider(width: 1),
        Expanded(flex: 2, child: _buildTutorialSection()),
      ],
    );
  }

  Widget _buildFaqSection() {
    final categories = ['All', ...faqItems.map((e) => e.category).toSet()];
    final filteredFaqs = _selectedFaqCategory == 'All'
        ? faqItems
        : faqItems
              .where((faq) => faq.category == _selectedFaqCategory)
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Frequently Asked Questions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    final isSelected = category == _selectedFaqCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(category),
                        onSelected: (selected) {
                          setState(() {
                            _selectedFaqCategory = category;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredFaqs.length,
            itemBuilder: (context, index) {
              final faq = filteredFaqs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  title: Text(
                    faq.question,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    faq.category,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        faq.answer,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return Consumer(
      builder: (context, ref, child) {
        final formState = ref.watch(supportFormProvider);

        if (formState.isSubmitted) {
          return _buildSuccessView();
        }

        return _buildSupportForm(formState);
      },
    );
  }

  Widget _buildSupportForm(SupportFormState formState) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final subjectController = TextEditingController();
    final messageController = TextEditingController();
    String selectedPriority = 'Medium';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Support',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Having trouble? We\'re here to help!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            if (formState.error != null) ...[
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          formState.error!,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email address',
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                hintText: 'Brief description of your issue',
                prefixIcon: Icon(Icons.subject),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a subject';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                prefixIcon: Icon(Icons.priority_high),
              ),
              items: ['Low', 'Medium', 'High', 'Urgent']
                  .map(
                    (priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(priority),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedPriority = value;
                }
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Describe your issue in detail...',
                prefixIcon: Icon(Icons.message),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your message';
                }
                if (value.trim().length < 10) {
                  return 'Message must be at least 10 characters long';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: formState.isSubmitting
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          final ticket = SupportTicket(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            subject: subjectController.text.trim(),
                            message: messageController.text.trim(),
                            priority: selectedPriority,
                          );

                          await ref
                              .read(supportFormProvider.notifier)
                              .submitTicket(ticket);
                        }
                      },
                child: formState.isSubmitting
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Submitting...'),
                        ],
                      )
                    : const Text('Submit Support Ticket'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Ticket Submitted Successfully!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ve received your support request and will get back to you within 24 hours.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                ref.read(supportFormProvider.notifier).reset();
              },
              child: const Text('Submit Another Ticket'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Video Tutorials',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Learn how to use our platform with these helpful guides',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tutorials.length,
            itemBuilder: (context, index) {
              final tutorial = tutorials[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _playTutorial(tutorial),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).colorScheme.surfaceVariant,
                          ),
                          child: Icon(
                            Icons.play_circle_filled,
                            color: Theme.of(context).colorScheme.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tutorial.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tutorial.description,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${tutorial.duration.inMinutes}:${(tutorial.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _playTutorial(Tutorial tutorial) {
    // Here you would typically navigate to a video player or open the video URL
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tutorial.title),
        content: Text('This would open the video: ${tutorial.videoUrl}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
