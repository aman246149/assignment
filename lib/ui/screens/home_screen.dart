import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assignment/controllers/conversation.dart';
import 'package:assignment/controllers/user.dart';
import 'package:assignment/model/conversation.dart';
import 'package:assignment/model/user.dart';
import 'package:assignment/ui/screens/chat_screen.dart';
import 'package:assignment/ui/screens/tabs/chat_history_tab.dart';
import 'package:assignment/ui/screens/tabs/users_tab.dart';
import 'package:assignment/ui/widgets/bottom_nav_bar.dart';
import 'package:assignment/ui/widgets/tab_switcher.dart';
import 'package:assignment/ui/widgets/top_snackbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  int _bottomNavIndex = 0;
  final PageController _pageController = PageController();

  final List<String> _tabNames = ['Users', 'Chat History'];
  final List<String> _mockNames = [
    'Alice Johnson',
    'Bob Smith',
    'Carol Williams',
    'David Brown',
    'Emma Davis',
    'Frank Miller',
    'Grace Wilson',
    'Henry Moore',
  ];
  int _nameIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final userController = context.read<UserController>();
    final conversationController = context.read<ConversationController>();
    await userController.getAllUsers();
    await conversationController.loadConversations();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  Future<void> _addUser() async {
    final name = _mockNames[_nameIndex % _mockNames.length];
    _nameIndex++;

    final userController = context.read<UserController>();
    await userController.addUser(name);

    if (mounted) {
      TopSnackbar.show(context, 'User added: $name');
    }
  }

  Future<void> _navigateToChat(User user) async {
    final conversationController = context.read<ConversationController>();
    final conversation = await conversationController.getOrCreateConversation(
      user.id,
    );

    if (mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              ChatScreen(user: user, conversation: conversation),
        ),
      );
      // Reload conversations to update last message and time
      if (mounted) {
        await conversationController.loadConversations();
      }
    }
  }

  Future<void> _navigateToChatFromHistory(Conversation conversation) async {
    final userController = context.read<UserController>();
    final conversationController = context.read<ConversationController>();
    final user = userController.users
        .where((u) => u.id == conversation.userId)
        .firstOrNull;

    if (user != null && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              ChatScreen(user: user, conversation: conversation),
        ),
      );
      // Reload conversations to update last message and time
      if (mounted) {
        await conversationController.loadConversations();
      }
    }
  }

  Widget _buildBody() {
    switch (_bottomNavIndex) {
      case 0:
        // Home - show the main chat UI
        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                floating: true,
                snap: true,
                title: TabSwitcher(
                  tabs: _tabNames,
                  selectedIndex: _selectedTabIndex,
                  onChanged: _onTabChanged,
                ),
                centerTitle: true,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
              ),
            ];
          },
          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              UsersTab(onUserTap: _navigateToChat),
              ChatHistoryTab(onConversationTap: _navigateToChatFromHistory),
            ],
          ),
        );
      case 1:
        // Offers
        return const Center(
          child: Text(
            'Offers',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        );
      case 2:
        // Settings
        return const Center(
          child: Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: _bottomNavIndex == 0 && _selectedTabIndex == 0
          ? FloatingActionButton(
              onPressed: _addUser,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
      ),
    );
  }
}
