// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/ui/screens/home_screen.dart';
import 'package:assignment/controllers/user.dart';
import 'package:assignment/controllers/conversation.dart';
import 'package:assignment/controllers/message.dart';
import 'package:assignment/repository/user.dart';
import 'package:assignment/repository/conversation.dart';
import 'package:assignment/repository/message.dart';
import 'package:assignment/db_model/user.dart';
import 'package:assignment/db_model/conversation.dart';
import 'package:assignment/db_model/message.dart';
import 'package:assignment/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('HomeScreen renders correctly', (WidgetTester tester) async {
    // Initialize Hive for testing
    await Hive.initFlutter();

    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(MessageHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ConversationHiveAdapter());
    }

    // Open test boxes
    final usersBox = await Hive.openBox<UserHive>('test_users');
    final conversationsBox = await Hive.openBox<ConversationHive>(
      'test_conversations',
    );
    final messagesBox = await Hive.openBox<MessageHive>('test_messages');

    // Create repositories
    final userRepository = UserRepository(usersBox);
    final conversationRepository = ConversationRepository(conversationsBox);
    final messageRepository = MessageRepository(messagesBox);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserController(userRepository)),
          ChangeNotifierProvider(
            create: (_) =>
                MessageController(messageRepository, conversationRepository),
          ),
          ChangeNotifierProvider(
            create: (_) => ConversationController(
              conversationRepository,
              messageRepository,
              userRepository,
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );

    // Verify that HomeScreen renders with tab switcher
    expect(find.text('Users'), findsOneWidget);
    expect(find.text('Chat History'), findsOneWidget);

    // Clean up
    await usersBox.close();
    await conversationsBox.close();
    await messagesBox.close();
  });
}
