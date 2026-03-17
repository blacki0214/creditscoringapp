import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/loan_viewmodel.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';
import '../loan/loan_application_page.dart';
import '../settings/settings_page.dart';
import '../settings/profile_page.dart';
import '../settings/support_page.dart';
import '../loan/step3_additional_info.dart';
import '../widgets/add_password_dialog.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'application_contract_status_page.dart';
import '../utils/app_localization.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ApplicationStatus? _lastKnownStatus;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkAndPromptAddPassword();
  }

  // REMOVED didChangeDependencies - it was causing infinite loop!
  // Every time HomeViewModel called notifyListeners(), it triggered
  // didChangeDependencies → _loadUserData → notifyListeners → repeat infinitely
  // This caused hundreds of Firestore queries per second and memory leak

  void _loadUserData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null && mounted) {
        print('HomePage: Loading user data for $userId');
        context.read<HomeViewModel>().loadAllUserData(userId);

        // Also check if loan was just scored and refresh credit score
        _checkAndRefreshCreditScore();
      }
    });
  }

  Future<void> _checkAndPromptAddPassword() async {
    // Check if user signed in with Google and doesn't have password
    await Future.delayed(const Duration(seconds: 2)); // Wait for UI to settle

    if (!mounted) return;

    final authViewModel = context.read<AuthViewModel>();
    final hasPassword = await authViewModel.checkUserHasPassword();

    // Check if user already dismissed this prompt
    final hasSeenPrompt = await LocalStorageService.hasSeenAddPasswordPrompt();

    if (!hasPassword && !hasSeenPrompt && mounted) {
      _showAddPasswordPrompt();
    }
  }

  void _showAddPasswordPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Color(0xFF4C40F7)),
            SizedBox(width: 8),
            Text('Add a Password'),
          ],
        ),
        content: const Text(
          'You\'re signed in with Google. Would you like to add a password for easier access?\n\n'
          'Benefits:\n'
          '✓ Sign in without Google\n'
          '✓ Use "Forgot Password"\n'
          '✓ Backup sign-in method',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await LocalStorageService.setAddPasswordPromptSeen();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddPasswordDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C40F7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Add Password',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPasswordDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddPasswordDialog(),
    );

    if (result == true && mounted) {
      // Password was successfully added, mark prompt as seen
      await LocalStorageService.setAddPasswordPromptSeen();
    }
  }

  void _checkAndRefreshCreditScore() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final loanViewModel = context.read<LoanViewModel>();
      final homeViewModel = context.read<HomeViewModel>();
      final userId = FirebaseAuth.instance.currentUser?.uid;

      // If loan status changed to scored, refresh the credit score
      if (loanViewModel.isApplicationScored &&
          _lastKnownStatus != ApplicationStatus.scored &&
          userId != null) {
        print('HomePage: Loan scored! Refreshing credit score...');
        homeViewModel.refreshCreditScore(userId);
        _lastKnownStatus = ApplicationStatus.scored;
      } else if (loanViewModel.isApplicationProcessing) {
        _lastKnownStatus = ApplicationStatus.processing;
      } else if (loanViewModel.isApplicationRejected) {
        _lastKnownStatus = ApplicationStatus.rejected;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    // Check if we need to refresh credit score when loan status changes
    _checkAndRefreshCreditScore();

    return Scaffold(
      backgroundColor: const Color(0xFF5A57F8),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4D4AF9), Color(0xFF6D7CFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4D4AF9).withOpacity(0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar with menu
                    PopupMenuButton(
                      offset: const Offset(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.8),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.white24,
                          backgroundImage: viewModel.userAvatar != null
                              ? NetworkImage(viewModel.userAvatar!)
                              : null,
                          child: viewModel.userAvatar == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(
                                Icons.settings_outlined,
                                color: Colors.grey.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Text('Settings'),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsPage(),
                              ),
                            );
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: Colors.grey.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Text('Profile'),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfilePage(),
                              ),
                            );
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(
                                Icons.support_agent_outlined,
                                color: Colors.grey.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Text('Support'),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SupportPage(),
                              ),
                            );
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.logout,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Logout',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Handle logout - navigate to login page
                            Navigator.of(
                              context,
                            ).pushNamedAndRemoveUntil('/', (route) => false);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (viewModel.userName ?? 'User').toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            FirebaseAuth.instance.currentUser?.email ?? '',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.78),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Notification with real-time updates
                    Builder(
                      builder: (context) {
                        final userId = FirebaseAuth.instance.currentUser?.uid;
                        if (userId == null) {
                          return const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                          );
                        }

                        return StreamBuilder<int>(
                          stream: NotificationService().getUnreadCountStream(
                            userId,
                          ),
                          builder: (context, countSnapshot) {
                            final unreadCount = countSnapshot.data ?? 0;

                            return PopupMenuButton(
                              offset: const Offset(0, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              icon: Stack(
                                children: [
                                  const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                  ),
                                  if (unreadCount > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          '$unreadCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                    enabled: false,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          context.t(
                                            'Notifications',
                                            'Thông báo',
                                          ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFF1A1F3F),
                                          ),
                                        ),
                                        if (unreadCount > 0)
                                          TextButton(
                                            onPressed: () async {
                                              await NotificationService()
                                                  .markAllAsRead(userId);
                                              // Don't close popup - let user see the updated state
                                            },
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: const Size(0, 0),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: Text(
                                              context.t(
                                                'Mark all read',
                                                'Đánh dấu đã đọc',
                                              ),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF4C40F7),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    enabled: false,
                                    child: Divider(height: 1),
                                  ),
                                  PopupMenuItem(
                                    enabled: false,
                                    child: SizedBox(
                                      width: 300,
                                      height: 300,
                                      child: StreamBuilder<List<NotificationModel>>(
                                        stream: NotificationService()
                                            .getNotificationsStream(userId),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }

                                          if (snapshot.hasError) {
                                            return Center(
                                              child: Text(
                                                context.t(
                                                  'Error loading notifications',
                                                  'Lỗi khi tải thông báo',
                                                ),
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            );
                                          }

                                          final notifications =
                                              snapshot.data ?? [];

                                          if (notifications.isEmpty) {
                                            return Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.notifications_none,
                                                    size: 48,
                                                    color: Colors.grey.shade400,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    context.t(
                                                      'No notifications yet',
                                                      'Chưa có thông báo',
                                                    ),
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }

                                          return ListView.separated(
                                            padding: EdgeInsets.zero,
                                            itemCount: notifications.length,
                                            separatorBuilder:
                                                (context, index) =>
                                                    const Divider(height: 1),
                                            itemBuilder: (context, index) {
                                              final notification =
                                                  notifications[index];
                                              return InkWell(
                                                onTap: () async {
                                                  if (!notification.isRead) {
                                                    await NotificationService()
                                                        .markAsRead(
                                                          notification.id,
                                                        );
                                                  }
                                                  // Don't close popup - let user continue browsing notifications
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 12,
                                                      ),
                                                  color: notification.isRead
                                                      ? const Color(0xFFF5F5F5)
                                                      : Colors.white,
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Color(
                                                            notification
                                                                .colorValue,
                                                          ).withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          border: notification
                                                                  .isRead
                                                              ? null
                                                              : Border.all(
                                                                  color: Color(
                                                                    notification
                                                                        .colorValue,
                                                                  ).withOpacity(
                                                                    0.35,
                                                                  ),
                                                                  width: 1.2,
                                                                ),
                                                        ),
                                                        child: Icon(
                                                          _getNotificationIcon(
                                                            notification.type,
                                                          ),
                                                          color: Color(
                                                            notification
                                                                .colorValue,
                                                          ),
                                                          size: notification
                                                                  .isRead
                                                              ? 20
                                                              : 22,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                if (!notification
                                                                    .isRead)
                                                                  Container(
                                                                    width: 8,
                                                                    height: 8,
                                                                    margin:
                                                                        const EdgeInsets.only(
                                                                          right:
                                                                              6,
                                                                        ),
                                                                    decoration: const BoxDecoration(
                                                                      color: Color(
                                                                        0xFF4C40F7,
                                                                      ),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                  ),
                                                                Expanded(
                                                                  child: Text(
                                                                    notification
                                                                        .title,
                                                                    style: TextStyle(
                                                                      fontWeight:
                                                                          notification
                                                                              .isRead
                                                                          ? FontWeight.w500
                                                                        : FontWeight.w700,
                                                                      fontSize:
                                                                          14,
                                                                      color: notification
                                                                              .isRead
                                                                          ? Colors.grey
                                                                              .shade700
                                                                          : const Color(
                                                                              0xFF1A1F3F,
                                                                            ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 2,
                                                            ),
                                                            Text(
                                                              notification.body,
                                                              style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: notification
                                                                  .isRead
                                                                ? FontWeight.w400
                                                                : FontWeight.w600,
                                                              color: notification
                                                                  .isRead
                                                                ? Colors
                                                                  .grey
                                                                  .shade600
                                                                : Colors
                                                                  .grey
                                                                  .shade800,
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Text(
                                                              notification
                                                                  .timeAgo,
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                color: Colors
                                                                    .grey
                                                                    .shade500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ];
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Main content card
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting
                        Text(
                          context.t(
                            'Hello, ${viewModel.userName ?? "User"}',
                            'Xin chào, ${viewModel.userName ?? "Bạn"}',
                          ),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1F3F),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.t(
                            'Here is your credit rate',
                            'Đây là mức tín dụng của bạn',
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Period selector
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildPeriodChip(context, viewModel, 'Overall'),
                              const SizedBox(width: 8),
                              _buildPeriodChip(
                                context,
                                viewModel,
                                'Scoring Status',
                              ),
                              const SizedBox(width: 8),
                              _buildPeriodChip(
                                context,
                                viewModel,
                                'Loan History',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Content based on selected period
                        if (viewModel.selectedPeriod == 'Overall') ...[
                          // Credit score gauge
                          if (viewModel.creditScore != null) ...[
                            Center(
                              child: SizedBox(
                                width: 250,
                                height: 200,
                                child: CustomPaint(
                                  painter: CreditScoreGaugePainter(
                                    score: viewModel.creditScore!,
                                    hasData: true,
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 60),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${viewModel.creditScore}',
                                            style: const TextStyle(
                                              fontSize: 48,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1A1F3F),
                                            ),
                                          ),
                                          Text(
                                            context.t(
                                              'Your credit score',
                                              'Điểm tín dụng của bạn',
                                            ),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            // No credit score state
                            Center(
                              child: SizedBox(
                                width: 250,
                                height: 200,
                                child: CustomPaint(
                                  painter: CreditScoreGaugePainter(
                                    score: 0,
                                    hasData: false,
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 60),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.credit_score_outlined,
                                            size: 48,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            context.t(
                                              'No data yet',
                                              'Chưa có dữ liệu',
                                            ),
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            context.t(
                                              'credit score',
                                              'điểm tín dụng',
                                            ),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          // Score info
                          if (viewModel.creditScore != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      context.t('starting score', 'điểm ban đầu'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${viewModel.startingScore ?? viewModel.creditScore}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1F3F),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      context.t(
                                        'change to date',
                                        'thay đổi đến hiện tại',
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${viewModel.scoreChange >= 0 ? "+" : ""}${viewModel.scoreChange}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: viewModel.scoreChange >= 0
                                            ? const Color(0xFF4CAF50)
                                            : const Color(0xFFEF5350),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 24),
                          // Update button
                          Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                final userId =
                                    FirebaseAuth.instance.currentUser?.uid;
                                if (userId != null) {
                                  if (viewModel.creditScore != null) {
                                    // Refresh credit score
                                    await viewModel.refreshCreditScore(userId);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            context.t(
                                              'Credit score updated!',
                                              'Đã cập nhật điểm tín dụng!',
                                            ),
                                          ),
                                          backgroundColor: Color(0xFF4CAF50),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  } else {
                                    // Navigate to loan application
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const LoanApplicationPage(),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: viewModel.creditScore != null
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFF4C40F7),
                                foregroundColor: viewModel.creditScore != null
                                    ? const Color(0xFF4CAF50)
                                    : Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                viewModel.creditScore != null
                                    ? context.t(
                                        'Update your credit score',
                                        'Cập nhật điểm tín dụng',
                                      )
                                    : context.t(
                                        'Apply for loan now',
                                        'Đăng ký vay ngay',
                                      ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          // Credit Score Tips Section
                          const SizedBox(height: 32),
                          _buildCreditScoreTips(
                            context,
                            creditScore: viewModel.creditScore,
                          ),
                        ] else if (viewModel.selectedPeriod ==
                            'Scoring Status') ...[
                          // Loan display section
                          _buildLoanDisplay(context),
                        ] else if (viewModel.selectedPeriod ==
                            'Loan History') ...[
                          _buildLoanHistoryDisplay(context),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanDisplay(BuildContext context) {
    final loanViewModel = context.watch<LoanViewModel>();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final activeOffer =
        loanViewModel.currentOffer ?? loanViewModel.lastCompletedOffer;
    final activeStatus =
        loanViewModel.applicationStatus != ApplicationStatus.none
        ? loanViewModel.applicationStatus
        : loanViewModel.lastCompletedStatus;
    final isActiveFromHistory =
        activeOffer != null && loanViewModel.currentOffer == null;
    final showScoreStatus =
        loanViewModel.currentOffer != null ||
        activeStatus == ApplicationStatus.processing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Loan Status Box
        if (showScoreStatus) ...[
          const Text(
            'Score Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1F3F),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: activeStatus == ApplicationStatus.processing
                  ? const Color(0xFFFFF3E0)
                  : activeStatus == ApplicationStatus.scored
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: activeStatus == ApplicationStatus.processing
                    ? const Color(0xFFFFA726)
                    : activeStatus == ApplicationStatus.scored
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFEF5350),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  activeStatus == ApplicationStatus.processing
                      ? Icons.hourglass_empty
                      : activeStatus == ApplicationStatus.scored
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: activeStatus == ApplicationStatus.processing
                      ? const Color(0xFFFFA726)
                      : activeStatus == ApplicationStatus.scored
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFEF5350),
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeStatus == ApplicationStatus.processing
                            ? 'Scoring (In Progress)'
                            : activeStatus == ApplicationStatus.scored
                            ? 'Scored'
                            : 'Rejected',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: activeStatus == ApplicationStatus.processing
                              ? const Color(0xFFFFA726)
                              : activeStatus == ApplicationStatus.scored
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFEF5350),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeStatus == ApplicationStatus.processing
                            ? 'We are calculating your credit score...'
                            : activeStatus == ApplicationStatus.scored
                            ? 'Your score has been calculated successfully'
                            : 'Your application was not approved',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      // Show loan amount in the scored box
                      if (activeStatus == ApplicationStatus.scored &&
                          activeOffer != null &&
                          activeOffer['approved'] as bool) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Limit Amount',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF1A1F3F),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                currencyFormat.format(
                                  activeOffer['maxAmountVnd'] as num,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Continue button to Step 3 (only show for active flow)
                        if (!isActiveFromHistory &&
                            (!loanViewModel.step3Completed ||
                                !loanViewModel.step4Completed))
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const Step3AdditionalInfoPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4C40F7),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Current Loan Offer Section (only show full details after Step 3 & 4 completion)
        if (activeOffer != null &&
            activeStatus == ApplicationStatus.scored &&
            (isActiveFromHistory ||
                (loanViewModel.step3Completed &&
                    loanViewModel.step4Completed))) ...[
          const Text(
            'Current Loan Offer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1F3F),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (activeOffer['approved'] as bool? ?? true)
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (activeOffer['approved'] as bool? ?? true)
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFEF5350),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (activeOffer['approved'] as bool? ?? true)
                          ? 'APPROVED'
                          : 'REJECTED',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: (activeOffer['approved'] as bool? ?? true)
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFEF5350),
                      ),
                    ),
                    Icon(
                      (activeOffer['approved'] as bool? ?? true)
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: (activeOffer['approved'] as bool? ?? true)
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFEF5350),
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (activeOffer['approved'] as bool) ...[
                  // Show the actual loan amount user chose
                  if (activeOffer['loanAmountVnd'] != null)
                    Column(
                      children: [
                        _buildLoanDetailRow(
                          'Loan Amount',
                          currencyFormat.format(
                            activeOffer['loanAmountVnd'] as num,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  if (activeOffer['interestRate'] != null)
                    Column(
                      children: [
                        _buildLoanDetailRow(
                          'Interest Rate',
                          '${(activeOffer['interestRate'] as num).toStringAsFixed(2)}% / year',
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  if (activeOffer['monthlyPaymentVnd'] != null)
                    Column(
                      children: [
                        _buildLoanDetailRow(
                          'Monthly Payment',
                          currencyFormat.format(
                            activeOffer['monthlyPaymentVnd'] as num,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  if (activeOffer['loanTermMonths'] != null)
                    Column(
                      children: [
                        _buildLoanDetailRow(
                          'Loan Term',
                          '${activeOffer['loanTermMonths']} months',
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  _buildLoanDetailRow(
                    'Credit Score',
                    '${activeOffer['creditScore']}',
                  ),
                ] else ...[
                  Center(
                    child: Column(
                      children: [
                        Text(
                          activeOffer['approvalMessage'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFEF5350),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        _buildLoanDetailRow(
                          'Credit Score',
                          '${activeOffer['creditScore']}',
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
        ] else if (activeStatus == ApplicationStatus.none) ...[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.money_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No Active Loan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start a new loan application',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoanApplicationPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C40F7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Apply Now'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoanHistoryDisplay(BuildContext context) {
    final applicationHistory = LocalStorageService.getApplicationHistory();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    if (applicationHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Applications Yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your loan applications will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Application History',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1F3F),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: applicationHistory.length,
          itemBuilder: (context, index) {
            final app = applicationHistory[index];
            final timestampRaw = app['timestamp'] ?? app['submitted_at'];
            final timestamp = timestampRaw != null
                ? DateTime.parse(timestampRaw)
                : DateTime.now();
            final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
            final isApproved = app['approved'] == true;

            return InkWell(
              onTap: isApproved
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ApplicationContractStatusPage(
                            application: Map<String, dynamic>.from(app),
                          ),
                        ),
                      );
                    }
                  : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isApproved
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFEF5350),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isApproved ? Icons.check_circle : Icons.cancel,
                      color: isApproved
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFEF5350),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isApproved ? 'Approved' : 'Rejected',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isApproved
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFEF5350),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (isApproved) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Tap to view contract status',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (isApproved &&
                            app['loanAmount'] != null &&
                            (app['loanAmount'] as num) > 0)
                          Text(
                            currencyFormat.format(app['loanAmount']),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1F3F),
                            ),
                          )
                        else if (!isApproved)
                          Text(
                            'Not approved',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                    if (isApproved) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoanDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1F3F),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodChip(
    BuildContext context,
    HomeViewModel viewModel,
    String label,
  ) {
    final isSelected = viewModel.selectedPeriod == label;
    return GestureDetector(
      onTap: () {
        viewModel.setPeriod(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1F3F) : const Color(0xFFE6E9F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1A1F3F)
                : const Color(0xFFC9D1E6),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1A1F3F).withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          context.t(label, _periodLabelVi(label)),
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF2B335A),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String _periodLabelVi(String label) {
    switch (label) {
      case 'Overall':
        return 'Tổng quan';
      case 'Scoring Status':
        return 'Trạng thái chấm điểm';
      case 'Loan History':
        return 'Lịch sử khoản vay';
      default:
        return label;
    }
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    Color indicatorColor,
  ) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF252B4C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Value: $value',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Text(
                  'This metric affects your credit score. Keep monitoring it regularly for the best results.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Color(0xFF4C40F7)),
                ),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1F3F),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class CreditScoreGaugePainter extends CustomPainter {
  final int score;
  final bool hasData;

  CreditScoreGaugePainter({required this.score, this.hasData = true});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.75);
    final radius = size.width * 0.4;
    final strokeWidth = 20.0;

    // Background arc
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      backgroundPaint,
    );

    if (hasData) {
      // Color segments for score ranges
      final segments = [
        {'color': const Color(0xFFFF5252), 'start': 0.0, 'sweep': 0.25}, // Poor
        {
          'color': const Color(0xFFFFA726),
          'start': 0.25,
          'sweep': 0.25,
        }, // Fair
        {'color': const Color(0xFFFFEB3B), 'start': 0.5, 'sweep': 0.25}, // Good
        {
          'color': const Color(0xFF4CAF50),
          'start': 0.75,
          'sweep': 0.25,
        }, // Excellent
      ];

      for (var segment in segments) {
        final paint = Paint()
          ..color = segment['color'] as Color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          math.pi + (math.pi * (segment['start'] as double)),
          math.pi * (segment['sweep'] as double),
          false,
          paint,
        );
      }

      // Indicator needle
      final scorePercentage = ((score - 300) / (850 - 300)).clamp(0.0, 1.0);
      final angle = math.pi + (math.pi * scorePercentage);

      final needlePaint = Paint()
        ..color = const Color(0xFF1A1F3F)
        ..style = PaintingStyle.fill;

      final needleLength = radius - 10;
      final needleEnd = Offset(
        center.dx + needleLength * math.cos(angle),
        center.dy + needleLength * math.sin(angle),
      );

      // Draw needle circle
      canvas.drawCircle(center, 8, needlePaint);

      // Draw needle line
      final needleLinePaint = Paint()
        ..color = const Color(0xFF1A1F3F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(center, needleEnd, needleLinePaint);
    } else {
      // Draw gray arc when no data
      final grayPaint = Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        math.pi,
        false,
        grayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Widget to build credit score tips section
Widget _buildCreditScoreTips(
  BuildContext context, {
  required int? creditScore,
}) {
  final score = creditScore;
  final hasScore = score != null;
  final isLow = hasScore && score < 580;
  final isMid = hasScore && score >= 580 && score < 700;
  final isGood = hasScore && score >= 700;

  final Color accentColor = !hasScore
      ? Colors.grey
      : isLow
      ? const Color(0xFFD32F2F)
      : isMid
      ? const Color(0xFFF57C00)
      : const Color(0xFF2E7D32);

  final IconData headerIcon = !hasScore
      ? Icons.info_outline
      : isGood
      ? Icons.verified
      : Icons.lightbulb_outline;

  final String headerTitle = !hasScore
      ? context.t('Credit Score Tips', 'Mẹo cải thiện điểm tín dụng')
      : isGood
      ? context.t('Congratulations', 'Chúc mừng')
      : context.t(
          'How to Improve Your Credit Score',
          'Cách cải thiện điểm tín dụng',
        );

  final String subtitleText = !hasScore
      ? context.t(
          'We need more information to generate personalized tips.',
          'Chúng tôi cần thêm thông tin để tạo gợi ý phù hợp cho bạn.',
        )
      : isGood
      ? context.t(
          'Your credit score is perfect. Keep up the great habits!',
          'Điểm tín dụng của bạn rất tốt. Hãy tiếp tục duy trì thói quen này!',
        )
      : isLow
      ? context.t(
          'Your score is low. Try these steps to improve it.',
          'Điểm của bạn còn thấp. Hãy thử các bước sau để cải thiện.',
        )
      : context.t(
          'Your score is fair. These tips can help you move higher.',
          'Điểm của bạn ở mức trung bình. Các mẹo sau sẽ giúp bạn cải thiện.',
        );

  // This returns a Column widget which stacks widgets vertically
  return Column(
    // crossAxisAlignment aligns children to the start (left side)
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Section title with icon
      Row(
        children: [
          // Icon representing tips/lightbulb moment
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // Light background for the icon
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(headerIcon, color: accentColor, size: 24),
          ),
          const SizedBox(width: 12),
          // Title text
          Expanded(
            child: Text(
              headerTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1F3F),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      // Subtitle/description
      Text(
        subtitleText,
        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
      ),
      const SizedBox(height: 20),

      if (!hasScore)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.grey.shade600, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.t(
                    'Complete your profile and submit an application to see tailored credit score tips.',
                    'Hãy hoàn thiện hồ sơ và gửi đơn vay để xem các mẹo điểm tín dụng phù hợp.',
                  ),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
        )
      else if (isGood)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2E7D32)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2E7D32),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.t(
                    'Your credit score is perfect. Keep paying on time and maintaining low balances to stay in the top tier.',
                    'Điểm tín dụng của bạn rất tốt. Hãy tiếp tục thanh toán đúng hạn và giữ dư nợ thấp để duy trì mức cao nhất.',
                  ),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                ),
              ),
            ],
          ),
        )
      else ...[
        // Tip 1: Pay on time
        _buildTipCard(
          icon: Icons.schedule,
          iconColor: const Color(0xFF4CAF50),
          iconBgColor: const Color(0xFFE8F5E9),
          title: context.t('1. Pay Bills on Time', '1. Thanh toán đúng hạn'),
          description: context.t(
            'Payment history is the most important factor (35% of your score). Set up automatic payments or reminders to never miss a due date.',
            'Lịch sử thanh toán là yếu tố quan trọng nhất (35% điểm số). Hãy bật tự động thanh toán hoặc nhắc nhở để không trễ hạn.',
          ),
          tips: [
            context.t(
              'Set up autopay for recurring bills',
              'Bật tự động thanh toán cho hóa đơn định kỳ',
            ),
            context.t(
              'Use calendar reminders 3 days before due dates',
              'Đặt nhắc lịch trước hạn thanh toán 3 ngày',
            ),
            context.t(
              'Pay at least the minimum amount required',
              'Thanh toán ít nhất số tiền tối thiểu',
            ),
            context.t(
              'Consider bi-weekly payments to stay ahead',
              'Cân nhắc trả 2 tuần/lần để chủ động hơn',
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Tip 2: Keep credit utilization low
        _buildTipCard(
          icon: Icons.credit_card,
          iconColor: const Color(0xFF2196F3),
          iconBgColor: const Color(0xFFE3F2FD),
          title: context.t(
            '2. Keep Credit Utilization Below 30%',
            '2. Giữ tỷ lệ sử dụng tín dụng dưới 30%',
          ),
          description: context.t(
            'Credit utilization (30% of your score) is the ratio of your credit card balances to credit limits. Lower is better.',
            'Tỷ lệ sử dụng tín dụng (30% điểm số) là tỷ lệ dư nợ thẻ trên hạn mức. Tỷ lệ càng thấp càng tốt.',
          ),
          tips: [
            context.t(
              'Try to use less than 30% of your available credit',
              'Cố gắng sử dụng dưới 30% hạn mức tín dụng',
            ),
            context.t(
              'Pay down balances before statement closing dates',
              'Giảm dư nợ trước ngày chốt sao kê',
            ),
            context.t(
              'Request credit limit increases (but don\'t spend more)',
              'Xin tăng hạn mức tín dụng (nhưng không chi tiêu nhiều hơn)',
            ),
            context.t(
              'Spread charges across multiple cards if needed',
              'Phân bổ chi tiêu trên nhiều thẻ khi cần',
            ),
          ],
        ),

        if (isLow) ...[
          const SizedBox(height: 16),

          // Tip 3: Limit new credit applications
          _buildTipCard(
            icon: Icons.playlist_add_check,
            iconColor: const Color(0xFF9C27B0),
            iconBgColor: const Color(0xFFF3E5F5),
            title: context.t(
              '3. Limit New Credit Applications',
              '3. Hạn chế mở tín dụng mới',
            ),
            description: context.t(
              'Each hard inquiry can lower your score by 5-10 points. New credit accounts for 10% of your score.',
              'Mỗi lần tra cứu tín dụng cứng có thể làm giảm 5-10 điểm. Yếu tố tín dụng mới chiếm 10% điểm số.',
            ),
            tips: [
              context.t(
                'Only apply for credit when you really need it',
                'Chỉ đăng ký tín dụng khi thực sự cần',
              ),
              context.t(
                'Multiple inquiries within 14-45 days count as one',
                'Nhiều lần tra cứu trong 14-45 ngày có thể được tính là một',
              ),
              context.t(
                'Avoid opening multiple accounts in a short time',
                'Tránh mở nhiều tài khoản trong thời gian ngắn',
              ),
              context.t(
                'Check your own credit (soft inquiry) regularly',
                'Thường xuyên tự kiểm tra tín dụng (tra cứu mềm)',
              ),
            ],
          ),
        ],
      ],
    ],
  );
}

// Widget to build individual tip card - reusable component
Widget _buildTipCard({
  required IconData icon,
  required Color iconColor,
  required Color iconBgColor,
  required String title,
  required String description,
  required List<String> tips,
}) {
  return TipCard(
    icon: icon,
    iconColor: iconColor,
    iconBgColor: iconBgColor,
    title: title,
    description: description,
    tips: tips,
  );
}

class TipCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String description;
  final List<String> tips;

  const TipCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.description,
    required this.tips,
  });

  @override
  State<TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<TipCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: widget.iconBgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.iconColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1F3F),
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      children: [
                        const SizedBox(height: 12),
                        Divider(color: Colors.grey.shade300, thickness: 1),
                        const SizedBox(height: 12),
                        ...widget.tips.map(
                          (tip) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 6,
                                    right: 12,
                                  ),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: widget.iconColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper function to get icon for notification type
IconData _getNotificationIcon(String type) {
  switch (type) {
    case 'loan_approved':
      return Icons.check_circle;
    case 'loan_rejected':
      return Icons.cancel;
    case 'credit_score_updated':
      return Icons.trending_up;
    case 'payment_reminder':
      return Icons.payment;
    default:
      return Icons.notifications;
  }
}
