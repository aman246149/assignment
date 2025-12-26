import 'package:assignment/constants/app_constant.dart' show AppConstant;
import 'package:assignment/controllers/conversation.dart';
import 'package:assignment/controllers/message.dart';
import 'package:assignment/controllers/user.dart';
import 'package:assignment/db_model/conversation.dart';
import 'package:assignment/db_model/message.dart';
import 'package:assignment/db_model/user.dart';
import 'package:assignment/repository/conversation.dart';
import 'package:assignment/repository/message.dart';
import 'package:assignment/repository/user.dart';
import 'package:assignment/ui/screens/home_screen.dart';
import 'package:assignment/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(UserHiveAdapter());
  Hive.registerAdapter(MessageHiveAdapter());
  Hive.registerAdapter(ConversationHiveAdapter());

  final usersBox = await Hive.openBox<UserHive>(AppConstant.usersBox);
  final conversationsBox = await Hive.openBox<ConversationHive>(
    AppConstant.conversationsBox,
  );
  final messagesBox = await Hive.openBox<MessageHive>(AppConstant.messagesBox);

  // Create repositories
  final userRepository = UserRepository(usersBox);
  final conversationRepository = ConversationRepository(conversationsBox);
  final messageRepository = MessageRepository(messagesBox);

  runApp(
    MyApp(
      userRepository: userRepository,
      conversationRepository: conversationRepository,
      messageRepository: messageRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final UserRepository userRepository;
  final ConversationRepository conversationRepository;
  final MessageRepository messageRepository;

  const MyApp({
    super.key,
    required this.userRepository,
    required this.conversationRepository,
    required this.messageRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
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
        title: 'Chat App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
