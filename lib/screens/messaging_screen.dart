import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/colors.dart';
import '../../utils/format.dart';

class MessagingScreen extends StatelessWidget {
  const MessagingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final conversations = [
      {
        'id': '1',
        'name': 'John Doe',
        'avatar': 'J',
        'lastMessage': 'Thank you for the bill reminder',
        'time': '2 min',
        'unread': true,
      },
      {
        'id': '2',
        'name': 'Jane Smith',
        'avatar': 'J',
        'lastMessage': 'I will pay by Friday',
        'time': '1 hour',
        'unread': false,
      },
      {
        'id': '3',
        'name': 'Support Team',
        'avatar': 'S',
        'lastMessage': 'Your issue has been resolved',
        'time': '5 hours',
        'unread': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {},
              child: const Icon(Icons.add_circle_outline),
            ),
          ),
        ],
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final isDark = themeProvider.isDarkMode;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conv = conversations[index];
              return _ConversationCard(conversation: conv, isDark: isDark);
            },
          );
        },
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final Map<String, dynamic> conversation;
  final bool isDark;

  const _ConversationCard({
    required this.conversation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgTertiary : Colors.white,
        border: Border.all(
          color: isDark ? AppColors.darkBgSecondary : AppColors.greyLighter,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.2),
            ),
            child: Center(
              child: Text(
                conversation['avatar'],
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      conversation['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      conversation['time'],
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  conversation['lastMessage'],
                  style: TextStyle(
                    color:
                        isDark ? AppColors.darkTextSecondary : AppColors.grey,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (conversation['unread'])
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
