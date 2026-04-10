import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/loan_viewmodel.dart';
import '../services/local_storage_service.dart';
import '../services/installment_service.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';
import '../loan/loan_application_page.dart';
import '../settings/settings_page.dart';
import '../settings/profile_page.dart';
import '../settings/support_page.dart';
import '../loan/step3_personal_info.dart';
import '../widgets/add_password_dialog.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'application_contract_status_page.dart';
import '../utils/app_localization.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.onOpenSettings,
    this.onOpenStudent,
    this.onOpenApplication,
  });

  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenStudent;
  final VoidCallback? onOpenApplication;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ApplicationStatus? _lastKnownStatus;
  final InstallmentService _installmentService = InstallmentService();
  int _selectedHomeTab = 0;

  void _openSettingsFromMenu() {
    if (widget.onOpenSettings != null) {
      widget.onOpenSettings!();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
  }

  void _openApplicationFromHome() {
    if (widget.onOpenApplication != null) {
      widget.onOpenApplication!();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoanApplicationPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkAndPromptAddPassword();
  }

  // REMOVED didChangeDependencies - it was causing infinite loop!
  // Every time HomeViewModel called notifyListeners(), it triggered
  // didChangeDependencies â†’ _loadUserData â†’ notifyListeners â†’ repeat infinitely
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
            Icon(Icons.lock_outline, color: Color(0xFF4D4AF9)),
            SizedBox(width: 8),
            Text('Add a Password'),
          ],
        ),
        content: const Text(
          'You\'re signed in with Google. Would you like to add a password for easier access?\n\n'
          'Benefits:\n'
          '�o" Sign in without Google\n'
          '�o" Use "Forgot Password"\n'
          '�o" Backup sign-in method',
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
              backgroundColor: const Color(0xFF4D4AF9),
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

  void _showNotificationsDialog(
    BuildContext context,
    String userId,
    int unreadCount,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 90,
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 468),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 10, 9),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.t('Notifications', 'Thông báo'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 25,
                              color: Color(0xFF1A1F3F),
                            ),
                          ),
                        ),
                        if (unreadCount > 0)
                          TextButton(
                            onPressed: () async {
                              await NotificationService().markAllAsRead(userId);
                            },
                            child: Text(
                              context.t('Mark all read', 'Đánh dấu đã đọc'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4D4AF9),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  Expanded(
                    child: StreamBuilder<List<NotificationModel>>(
                      stream: NotificationService().getNotificationsStream(
                        userId,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              context.t(
                                'Error loading notifications',
                                'Lỗi tải thông báo',
                              ),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }

                        final notifications = snapshot.data ?? [];

                        if (notifications.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(10),
                          itemCount: notifications.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 9),
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            final localizedTitle =
                                _getLocalizedNotificationTitle(
                                  context,
                                  notification,
                                );
                            final localizedBody = _getLocalizedNotificationBody(
                              context,
                              notification,
                            );
                            final localizedTimeAgo = _formatNotificationTimeAgo(
                              context,
                              notification.createdAt,
                            );

                            return InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () async {
                                if (!notification.isRead) {
                                  await NotificationService().markAsRead(
                                    notification.id,
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: notification.isRead
                                      ? const Color(0xFFF8FAFF)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: notification.isRead
                                        ? const Color(0xFFE6ECFF)
                                        : const Color(0xFFD8E2FF),
                                  ),
                                  boxShadow: notification.isRead
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF4D4AF9,
                                            ).withOpacity(0.06),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Color(
                                          notification.colorValue,
                                        ).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        _getNotificationIcon(notification.type),
                                        color: Color(notification.colorValue),
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 9),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              if (!notification.isRead)
                                                Container(
                                                  width: 7,
                                                  height: 7,
                                                  margin: const EdgeInsets.only(
                                                    right: 6,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Color(
                                                          0xFF4D4AF9,
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                ),
                                              Expanded(
                                                child: Text(
                                                  localizedTitle,
                                                  style: TextStyle(
                                                    fontWeight:
                                                        notification.isRead
                                                        ? FontWeight.w500
                                                        : FontWeight.w700,
                                                    fontSize: 15,
                                                    color: const Color(
                                                      0xFF1A1F3F,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            localizedBody,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade700,
                                              height: 1.2,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            localizedTimeAgo,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        splashRadius: 16,
                                        tooltip: context.t('Delete', 'Xóa'),
                                        onPressed: () async {
                                          await NotificationService()
                                              .deleteNotification(
                                                notification.id,
                                              );
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.red.shade400,
                                        ),
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
                  Divider(height: 1, color: Colors.grey.shade200),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4D4AF9),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                            child: Text(
                              context.t('Back', 'Quay lại'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await NotificationService()
                                  .deleteAllReadNotifications(userId);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE53935),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                            child: Text(
                              context.t(
                                'Delete all read',
                                'Xóa thông báo đã đọc',
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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

        if (_lastKnownStatus == ApplicationStatus.processing) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                context.t(
                  'Scoring completed. Your loan offer is ready.',
                  'Chấm điểm đã hoàn tất. Đề nghị khoản vay của bạn đã sẵn sàng.',
                ),
              ),
              backgroundColor: const Color(0xFF2E7D32),
              duration: const Duration(seconds: 5),
            ),
          );
        }

        _lastKnownStatus = ApplicationStatus.scored;
      } else if (loanViewModel.isApplicationProcessing) {
        _lastKnownStatus = ApplicationStatus.processing;
      } else if (loanViewModel.isApplicationRejected) {
        if (_lastKnownStatus == ApplicationStatus.processing) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                context.t(
                  'Scoring completed. This application was not approved.',
                  'Chấm điểm đã hoàn tất. Hồ sơ này không được duyệt.',
                ),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }

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
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      shadowColor: Colors.black26,
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
                            _openSettingsFromMenu();
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

                            return IconButton(
                              onPressed: () => _showNotificationsDialog(
                                context,
                                userId,
                                unreadCount,
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
                        const SizedBox(height: 8),
                        _buildDashboardTopTabs(context),
                        const SizedBox(height: 20),
                        _buildCreditStandingCard(context, viewModel),
                        const SizedBox(height: 20),
                        if (_selectedHomeTab == 0) ...[
                          _buildLoanDisplay(context),
                        ] else if (_selectedHomeTab == 1) ...[
                          _buildInstallmentDisplay(context),
                        ] else ...[
                          _buildStudentTabContent(context),
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

  Widget _buildDashboardTopTabs(BuildContext context) {
    final tabs = [
      context.t('Offer', 'Đề nghị'),
      context.t('Installment', 'Lịch trả góp'),
      context.t('Student', 'Sinh viên'),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedHomeTab == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedHomeTab == index) return;
                setState(() {
                  _selectedHomeTab = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? const Color(0xFF4D4AF9)
                        : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCreditStandingCard(
    BuildContext context,
    HomeViewModel viewModel,
  ) {
    final score = viewModel.creditScore;
    final scoreText = score?.toString() ?? '--';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            context.t('Your Credit Standing', 'Tình trạng tín dụng của bạn'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 250,
            height: 180,
            child: CustomPaint(
              painter: CreditScoreGaugePainter(
                score: score ?? 0,
                hasData: score != null,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 52),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        scoreText,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF86EFAC),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          context.t('Good', 'Tốt'),
                          style: const TextStyle(
                            color: Color(0xFF065F46),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Low\n300',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'High\n850',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTabContent(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('Get a Student Loan', 'Nhận khoản vay sinh viên'),
            style: const TextStyle(
              fontSize: 36,
              height: 1.1,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D2B8F),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.t(
              'Tailored rates for academic success and flexible repayment with Swin Credit.',
              'Lãi suất phù hợp cho hành trình học tập và lịch trả linh hoạt cùng Swin Credit.',
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF3F3BA0),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (widget.onOpenStudent != null) {
                widget.onOpenStudent!();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4D4AF9),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              context.t('Apply Now', 'Đăng ký ngay'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanDisplay(BuildContext context) {
    final loanViewModel = context.watch<LoanViewModel>();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final activeOffer = loanViewModel.currentOffer;
    final activeStatus = loanViewModel.applicationStatus;
    final showScoreStatus = activeStatus != ApplicationStatus.none;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Loan Status Box
        if (showScoreStatus) ...[
          Text(
            context.t('Application Center', 'Trung tâm hồ sơ vay'),
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
                            ? context.t(
                                'Processing Application',
                                'Đang xử lý hồ sơ',
                              )
                            : activeStatus == ApplicationStatus.scored
                            ? context.t('Offer Ready', 'Đã có đề nghị')
                            : context.t(
                                'Application Rejected',
                                'Hồ sơ bị từ chối',
                              ),
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
                            ? context.t(
                                'Please wait while we complete scoring and prepare your offer.',
                                'Vui lòng chờ trong khi chúng tôi hoàn tất chấm điểm và chuẩn bị đề nghị.',
                              )
                            : activeStatus == ApplicationStatus.scored
                            ? context.t(
                                'Your result is ready. Review the offer details and continue.',
                                'Kết quả đã sẵn sàng, Hãy xem chi tiết đề nghị và tiếp tục',
                              )
                            : context.t(
                                'Scoring is complete and this application was not approved.',
                                'Quá trình chấm điểm đã hoàn tất và hồ sơ này không được duyệt.',
                              ),
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
                              Expanded(
                                child: Text(
                                  context.t('Limit Amount', 'Hạn mức'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF1A1F3F),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      currencyFormat.format(
                                        activeOffer['maxAmountVnd'] as num,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF4CAF50),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Continue button to Step 3 (only show for active flow)
                        if (!loanViewModel.step3Completed ||
                            !loanViewModel.step4Completed)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const Step3PersonalInfoPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4D4AF9),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                context.t(
                                  'Continue To Complete Profile',
                                  'Tiếp tục để hoàn tất hồ sơ',
                                ),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],

                      // Show re-apply guidance for rejected applications
                      if (activeStatus == ApplicationStatus.rejected) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.t(
                                  'You can submit a new application after updating your profile details.',
                                  'Bạn có thể nộp hồ sơ mới sau khi cập nhật thông tin hồ sơ.',
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await loanViewModel
                                        .finalizeAndResetForNewApplication();
                                    if (!context.mounted) return;
                                    if (loanViewModel
                                        .hasCompletedOfferHistory) {
                                      loanViewModel
                                          .prepareReturningApplicantForNewLoan();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const Step3PersonalInfoPage(),
                                        ),
                                      );
                                    } else {
                                      _openApplicationFromHome();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4D4AF9),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 11,
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    context.t('Apply Again', 'Nộp hồ sơ mới'),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
            (loanViewModel.step3Completed && loanViewModel.step4Completed)) ...[
          Text(
            context.t('Current Offer', 'Đề nghị hiện tại'),
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
                          ? context.t('APPROVED', 'ĐÃ DUYỆT')
                          : context.t('REJECTED', 'TỪ CHỐI'),
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
                          context.t('Loan Amount', 'Số tiền vay'),
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
                          context.t('Interest Rate', 'Lãi suất'),
                          context.t(
                            '${(activeOffer['interestRate'] as num).toStringAsFixed(2)}% / year',
                            '${(activeOffer['interestRate'] as num).toStringAsFixed(2)}% / năm',
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  if (activeOffer['monthlyPaymentVnd'] != null)
                    Column(
                      children: [
                        _buildLoanDetailRow(
                          context.t('Monthly Payment', 'Thanh toán hàng tháng'),
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
                          context.t('Loan Term', 'Kỳ hạn vay'),
                          context.t(
                            '${activeOffer['loanTermMonths']} months',
                            '${activeOffer['loanTermMonths']} tháng',
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  _buildLoanDetailRow(
                    context.t('Credit Score', 'Điểm tín dụng'),
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
                          context.t('Credit Score', 'Điểm tín dụng'),
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
                  context.t(
                    'No Active Application',
                    'Không có hồ sơ đang xử lý',
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.t(
                    'Start a new loan application',
                    'Bắt đầu hồ sơ vay mới',
                  ),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _openApplicationFromHome();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D4AF9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(context.t('Apply Now', 'Đăng ký ngay')),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoanHistoryDisplay(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final applicationHistory = LocalStorageService.getApplicationHistory(
      userId: userId,
    );
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    if (applicationHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              context.t('No Applications Yet', 'Chưa có hồ sơ nào'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.t(
                'Your loan applications will appear here',
                'Các hồ sơ vay của bạn sẽ hiển thị tại đây',
              ),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    // Calculate pagination
    final totalApplications = applicationHistory.length;
    final totalPages = (totalApplications / viewModel.applicationsPerPage)
        .ceil();
    final startIndex =
        (viewModel.currentApplicationPage - 1) * viewModel.applicationsPerPage;
    final endIndex = (startIndex + viewModel.applicationsPerPage).clamp(
      0,
      totalApplications,
    );
    final paginatedHistory = applicationHistory.sublist(startIndex, endIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.t('Application History', 'Lịch sử hồ sơ'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1F3F),
              ),
            ),
            Text(
              '${viewModel.currentApplicationPage}/$totalPages',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: paginatedHistory.length,
          itemBuilder: (context, index) {
            final app = paginatedHistory[index];
            final timestampRaw = app['timestamp'] ?? app['submitted_at'];
            final timestamp = timestampRaw != null
                ? DateTime.parse(timestampRaw)
                : DateTime.now();
            final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
            final isApproved = app['approved'] == true;

            return Container(
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
                          isApproved
                              ? context.t('Approved', 'Đã duyệt')
                              : context.t('Rejected', 'Từ chối'),
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
                          context.t('Not approved', 'Không được duyệt'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        // Pagination controls
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: viewModel.currentApplicationPage > 1
                  ? () => viewModel.previousApplicationPage()
                  : null,
              icon: const Icon(Icons.chevron_left, size: 20),
              label: Text(context.t('Previous', 'Trước')),
              style: ElevatedButton.styleFrom(
                backgroundColor: viewModel.currentApplicationPage > 1
                    ? const Color(0xFF4D4AF9)
                    : Colors.grey.shade300,
                foregroundColor: viewModel.currentApplicationPage > 1
                    ? Colors.white
                    : Colors.grey.shade600,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: viewModel.currentApplicationPage < totalPages
                  ? () => viewModel.nextApplicationPage(totalApplications)
                  : null,
              icon: const Icon(Icons.chevron_right, size: 20),
              label: Text(context.t('Next', 'Tiếp')),
              style: ElevatedButton.styleFrom(
                backgroundColor: viewModel.currentApplicationPage < totalPages
                    ? const Color(0xFF4D4AF9)
                    : Colors.grey.shade300,
                foregroundColor: viewModel.currentApplicationPage < totalPages
                    ? Colors.white
                    : Colors.grey.shade600,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInstallmentDisplay(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    final userId = FirebaseAuth.instance.currentUser?.uid;
    final applicationHistory = LocalStorageService.getApplicationHistory(
      userId: userId,
    );
    final approvedApplications = applicationHistory
        .where((app) => app['approved'] == true)
        .toList();

    final totalInstallments = approvedApplications.length;
    final totalPages = (totalInstallments / viewModel.installmentsPerPage)
        .ceil();
    final startIndex =
        (viewModel.currentInstallmentPage - 1) * viewModel.installmentsPerPage;
    final endIndex = (startIndex + viewModel.installmentsPerPage).clamp(
      0,
      totalInstallments,
    );
    final paginatedInstallments = approvedApplications.sublist(
      startIndex,
      endIndex,
    );

    if (approvedApplications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              context.t('No Active Loans', 'Chưa có khoản vay đang hoạt động'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.t(
                'Accepted loans will show payment schedule',
                'Khoản vay được chấp nhận sẽ hiển thị lịch thanh toán',
              ),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.t('Payment Schedule', 'Lịch thanh toán'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1F3F),
              ),
            ),
            Text(
              '${viewModel.currentInstallmentPage}/$totalPages',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: paginatedInstallments.length,
          itemBuilder: (context, index) {
            final app = paginatedInstallments[index];
            final monthlyPayment =
                app['monthlyPayment'] ?? app['monthlyPaymentVnd'] ?? 0;
            final contractId =
                app['displayContractId'] ?? app['contractId'] ?? 'N/A';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.t(
                              'Monthly Repayment',
                              'Khoản trả hàng tháng',
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            currencyFormat.format(monthlyPayment),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            context.t('Due date', 'Ngày đến hạn'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          FutureBuilder<DateTime?>(
                            future: _getSyncedNextDueDateForApplication(app),
                            builder: (context, snapshot) {
                              final nextDueDate = snapshot.data;
                              return Text(
                                nextDueDate != null
                                    ? DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(nextDueDate)
                                    : '-',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1F3F),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ApplicationContractStatusPage(
                                    application: Map<String, dynamic>.from(app),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF0FF),
                                borderRadius: BorderRadius.circular(17),
                                border: Border.all(
                                  color: const Color(0xFFD9DDFE),
                                ),
                              ),
                              child: const Icon(
                                Icons.open_in_new,
                                size: 18,
                                color: Color(0xFF4D4AF9),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            context.t('Contract ID', 'ID Hợp đồng'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 180),
                            child: Text(
                              contractId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1F3F),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: viewModel.currentInstallmentPage > 1
                  ? () => viewModel.previousInstallmentPage()
                  : null,
              icon: const Icon(Icons.chevron_left, size: 20),
              label: Text(context.t('Previous', 'Trước')),
              style: ElevatedButton.styleFrom(
                backgroundColor: viewModel.currentInstallmentPage > 1
                    ? const Color(0xFF4D4AF9)
                    : Colors.grey.shade300,
                foregroundColor: viewModel.currentInstallmentPage > 1
                    ? Colors.white
                    : Colors.grey.shade600,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: viewModel.currentInstallmentPage < totalPages
                  ? () => viewModel.nextInstallmentPage(totalInstallments)
                  : null,
              icon: const Icon(Icons.chevron_right, size: 20),
              label: Text(context.t('Next', 'Tiếp')),
              style: ElevatedButton.styleFrom(
                backgroundColor: viewModel.currentInstallmentPage < totalPages
                    ? const Color(0xFF4D4AF9)
                    : Colors.grey.shade300,
                foregroundColor: viewModel.currentInstallmentPage < totalPages
                    ? Colors.white
                    : Colors.grey.shade600,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoanDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1F3F),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavChip(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF0FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFC8D3FF), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF3D477A)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                context.t(label, _getLabelVi(label)),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF3D477A),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLabelVi(String label) {
    switch (label) {
      case 'Offer':
        return 'Đề nghị';
      case 'Installment':
        return 'Lịch thanh toán';
      default:
        return label;
    }
  }

  Widget _buildPeriodChip(
    BuildContext context,
    HomeViewModel viewModel,
    String label,
  ) {
    final isSelected = viewModel.selectedPeriod == label;
    final icon = _periodIcon(label);

    return GestureDetector(
      onTap: () {
        viewModel.setPeriod(label);
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4D4AF9) : const Color(0xFFEAF0FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4D4AF9)
                : const Color(0xFFC8D3FF),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4D4AF9).withOpacity(0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFF3D477A),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                context.t(label, _periodLabelVi(label)),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF3D477A),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _periodIcon(String label) {
    switch (label) {
      case 'Overall':
        return Icons.dashboard_rounded;
      case 'Application Center':
        return Icons.hourglass_top_rounded;
      case 'Application History':
        return Icons.history_rounded;
      case 'Installment':
        return Icons.calendar_month_rounded;
      default:
        return Icons.circle;
    }
  }

  String _periodLabelVi(String label) {
    switch (label) {
      case 'Overall':
        return 'Tổng quan';
      case 'Application Center':
        return 'Trung tâm hồ sơ vay';
      case 'Application History':
        return 'Lịch sử hồ sơ';
      case 'Installment':
        return 'Lịch thanh toán';
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
                  style: TextStyle(color: Color(0xFF4D4AF9)),
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

  DateTime? _getNextDueDateFromSubmission(Map<String, dynamic> application) {
    final submittedAt = _getSubmissionDate(application);
    if (submittedAt == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    var nextDueDate = _addMonthsSafe(
      DateTime(submittedAt.year, submittedAt.month, submittedAt.day),
      1,
    );

    while (nextDueDate.isBefore(today)) {
      nextDueDate = _addMonthsSafe(nextDueDate, 1);
    }

    return nextDueDate;
  }

  DateTime? _getSubmissionDate(Map<String, dynamic> application) {
    final candidates = [
      application['submitted_at'],
      application['submittedAt'],
      application['timestamp'],
    ];

    for (final candidate in candidates) {
      if (candidate == null) continue;
      final parsed = DateTime.tryParse(candidate.toString());
      if (parsed != null) return parsed;
    }

    return null;
  }

  DateTime _addMonthsSafe(DateTime date, int monthsToAdd) {
    final totalMonths = (date.month - 1) + monthsToAdd;
    final year = date.year + (totalMonths ~/ 12);
    final month = (totalMonths % 12) + 1;
    final day = math.min(date.day, _daysInMonth(year, month));

    return DateTime(
      year,
      month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  int? _asNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  double? _asNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Future<DateTime?> _getSyncedNextDueDateForApplication(
    Map<String, dynamic> application,
  ) async {
    final submittedAt = _getSubmissionDate(application);
    if (submittedAt == null) return null;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    final offerId = await _resolveOfferIdForApplication(application, userId);

    if (offerId == null ||
        offerId.isEmpty ||
        userId == null ||
        userId.isEmpty) {
      return _getNextDueDateFromSubmission(application);
    }

    try {
      final installments = await _installmentService.getInstallmentsForLoan(
        userId: userId,
        loanOfferId: offerId,
      );
      final unpaid = installments.where((item) => !item.isPaid).toList();
      if (unpaid.isEmpty) return null;

      final paidCount = installments.where((item) => item.isPaid).length;
      final currentInstallmentNumber =
          await _getInstallmentNumberFromCreditApplication(
            application: application,
            userId: userId,
            fallbackValue: paidCount + 1,
          );
      return _addMonthsSafe(
        DateTime(submittedAt.year, submittedAt.month, submittedAt.day),
        currentInstallmentNumber,
      );
    } catch (_) {
      return _getNextDueDateFromSubmission(application);
    }
  }

  Future<int> _getInstallmentNumberFromCreditApplication({
    required Map<String, dynamic> application,
    required String userId,
    required int fallbackValue,
  }) async {
    final normalizedFallback = fallbackValue < 1 ? 1 : fallbackValue;
    final applicationId = _extractApplicationId(application);
    final offerId = _extractOfferId(application);

    try {
      DocumentSnapshot<Map<String, dynamic>>? appDoc;

      if (applicationId != null && applicationId.isNotEmpty) {
        final byId = await FirebaseFirestore.instance
            .collection('credit_applications')
            .doc(applicationId)
            .get();
        if (byId.exists) {
          appDoc = byId;
        }
      }

      if (appDoc == null && offerId != null && offerId.isNotEmpty) {
        final byOffer = await FirebaseFirestore.instance
            .collection('credit_applications')
            .where('userId', isEqualTo: userId)
            .where('offerId', isEqualTo: offerId)
            .limit(1)
            .get();

        if (byOffer.docs.isNotEmpty) {
          appDoc = byOffer.docs.first;
        }
      }

      final data = appDoc?.data();
      if (data == null) return normalizedFallback;

      final firestoreInstallmentNumber =
          _asNullableInt(data['installmentNumber']) ??
          _asNullableInt(data['currentInstallment']) ??
          _asNullableInt(data['currentInstallmentNumber']) ??
          _asNullableInt(data['installmentNo']) ??
          _asNullableInt(data['installment_no']);

      if (firestoreInstallmentNumber == null ||
          firestoreInstallmentNumber < 1) {
        return normalizedFallback;
      }

      return firestoreInstallmentNumber;
    } catch (_) {
      return normalizedFallback;
    }
  }

  String? _extractApplicationId(Map<String, dynamic> application) {
    final raw =
        application['applicationId'] ??
        application['creditApplicationId'] ??
        application['id'];
    final parsed = raw?.toString();
    if (parsed == null || parsed.isEmpty) return null;
    return parsed;
  }

  String? _extractOfferId(Map<String, dynamic> application) {
    final raw = application['offerId'] ?? application['loanOfferId'];
    final parsed = raw?.toString();
    if (parsed == null || parsed.isEmpty) return null;
    return parsed;
  }

  Future<String?> _resolveOfferIdForApplication(
    Map<String, dynamic> application,
    String? userId,
  ) async {
    final offerIdRaw = application['offerId'] ?? application['loanOfferId'];
    final directOfferId = offerIdRaw?.toString();
    if (directOfferId != null && directOfferId.isNotEmpty) {
      return directOfferId;
    }

    if (userId == null || userId.isEmpty) return null;

    try {
      final query = await FirebaseFirestore.instance
          .collection('loan_offers')
          .where('userId', isEqualTo: userId)
          .where('accepted', isEqualTo: true)
          .get();

      if (query.docs.isEmpty) return null;

      final appLoanAmount = _asNullableDouble(
        application['loanAmount'] ?? application['loanAmountVnd'],
      );
      final appTenorMonths = _asNullableInt(application['loanTermMonths']);
      final appMonthlyPayment = _asNullableDouble(
        application['monthlyPayment'] ?? application['monthlyPaymentVnd'],
      );

      QueryDocumentSnapshot<Map<String, dynamic>>? bestDoc;
      int bestScore = -1;

      for (final doc in query.docs) {
        final data = doc.data();
        int score = 0;

        final offerLoanAmount = _asNullableDouble(data['loanAmountVnd']);
        final offerTenorMonths = _asNullableInt(data['loanTermMonths']);
        final offerMonthlyPayment = _asNullableDouble(
          data['monthlyPaymentVnd'],
        );

        if (appLoanAmount != null && offerLoanAmount != null) {
          if ((appLoanAmount - offerLoanAmount).abs() < 1) score += 2;
        }
        if (appTenorMonths != null &&
            offerTenorMonths != null &&
            appTenorMonths == offerTenorMonths) {
          score += 2;
        }
        if (appMonthlyPayment != null && offerMonthlyPayment != null) {
          if ((appMonthlyPayment - offerMonthlyPayment).abs() < 1) score += 2;
        }

        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        if (createdAt != null) score += 1;

        if (score > bestScore) {
          bestScore = score;
          bestDoc = doc;
        }
      }

      return bestDoc?.id;
    } catch (_) {
      return null;
    }
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

String _getLocalizedNotificationTitle(
  BuildContext context,
  NotificationModel notification,
) {
  switch (notification.type) {
    case 'ekyc_completed':
      return context.t('eKYC Completed', 'eKYC đã hoàn tất');
    case 'step3_completed':
      return context.t('Step 3 Completed', 'Hoàn tất Bước 3');
    case 'step4_completed':
      return context.t('Step 4 Completed', 'Hoàn tất Bước 4');
    case 'step5_completed':
      return context.t('Step 5 Completed', 'Hoàn tất Bước 5');
    case 'loan_approved':
      return context.t('Loan Approved', 'Khoản vay đã được duyệt');
    case 'loan_rejected':
      return context.t('Loan Application Update', 'Cập nhật hồ sơ vay');
    case 'credit_score_updated':
      return context.t('Credit Score Updated', 'Điểm tín dụng đã cập nhật');
    case 'payment_reminder':
      return context.t('Payment Reminder', 'Nhắc nhở thanh toán');
    case 'payment_success':
      return context.t('Payment Successful', 'Thanh toán thành công');
    default:
      if (notification.title == 'Loan Approved') {
        return context.t('Loan Approved', 'Khoản vay đã được duyệt');
      }
      if (notification.title == 'Loan Application Update') {
        return context.t('Loan Application Update', 'Cập nhật hồ sơ vay');
      }
      if (notification.title == 'Credit Score Updated') {
        return context.t('Credit Score Updated', 'Điểm tín dụng đã cập nhật');
      }
      return normalizeMojibakeText(notification.title);
  }
}

String _getLocalizedNotificationBody(
  BuildContext context,
  NotificationModel notification,
) {
  final isVietnamese = context.isVietnamese;

  if (notification.type == 'loan_approved') {
    final rawAmount = notification.data?['loanAmount'];
    final amount = rawAmount is num ? rawAmount.toDouble() : null;
    final format = NumberFormat.currency(
      locale: isVietnamese ? 'vi_VN' : 'en_US',
      symbol: 'đ',
      decimalDigits: 0,
    );
    if (amount != null) {
      return context.t(
        'Your loan of ${format.format(amount)} has been approved',
        'Khoản vay ${format.format(amount)} của bạn đã được duyệt',
      );
    }
    return context.t(
      'Your loan has been approved',
      'Khoản vay của bạn đã được duyệt',
    );
  }

  if (notification.type == 'ekyc_completed') {
    return context.t(
      'Your identity verification is complete.',
      'Xác minh danh tính của bạn đã hoàn tất.',
    );
  }

  if (notification.type == 'step3_completed') {
    return context.t(
      'Additional information has been saved successfully.',
      'Thông tin bổ sung đã được lưu thành công.',
    );
  }

  if (notification.type == 'step4_completed') {
    return context.t(
      'Loan offer details are confirmed. Please review your contract.',
      'Thông tin đề nghị vay đã được xác nhận. Vui lòng xem lại hợp đồng.',
    );
  }

  if (notification.type == 'step5_completed') {
    return context.t(
      'Contract signed successfully. Continue to disbursement.',
      'Ký hợp đồng thành công. Tiếp tục sang bước giải ngân.',
    );
  }

  if (notification.type == 'loan_rejected') {
    return context.t(
      'Your loan application needs review',
      'Hồ sơ vay của bạn cần được xem xét thêm',
    );
  }

  if (notification.type == 'credit_score_updated') {
    final rawDifference = notification.data?['difference'];
    final difference = rawDifference is num ? rawDifference.toInt() : null;
    if (difference != null) {
      if (difference > 0) {
        return context.t(
          'Your score increased by $difference points',
          'Điểm tín dụng của bạn đã tăng $difference điểm',
        );
      }
      if (difference < 0) {
        return context.t(
          'Your score decreased by ${difference.abs()} points',
          'Điểm tín dụng của bạn đã giảm ${difference.abs()} điểm',
        );
      }
    }
    return context.t(
      'Your credit score was updated',
      'Điểm tín dụng của bạn đã được cập nhật',
    );
  }

  if (notification.type == 'payment_success') {
    final rawAmount = notification.data?['amountVnd'];
    final amount = rawAmount is num ? rawAmount.toDouble() : null;
    final format = NumberFormat.currency(
      locale: isVietnamese ? 'vi_VN' : 'en_US',
      symbol: 'đ',
      decimalDigits: 0,
    );
    if (amount != null) {
      return context.t(
        'We received your payment of ${format.format(amount)}.',
        'Chúng tôi đã nhận khoản thanh toán ${format.format(amount)} của bạn.',
      );
    }
    return context.t(
      'Your payment was completed successfully.',
      'Bạn đã thanh toán thành công.',
    );
  }

  if (notification.body == 'Your loan application needs review') {
    return context.t(
      'Your loan application needs review',
      'Hồ sơ vay của bạn cần được xem xét thêm',
    );
  }

  if (notification.body == 'Just now') {
    return context.t('Just now', 'Vừa xong');
  }

  return normalizeMojibakeText(
    notification.body
        .replaceAll('â‚«', 'đ')
        .replaceAll('₫', 'đ')
        .replaceAll('�,�', 'đ')
        .replaceAll('�?', ''),
  );
}

String _formatNotificationTimeAgo(BuildContext context, DateTime createdAt) {
  final now = DateTime.now();
  final difference = now.difference(createdAt);

  if (difference.inDays > 7) {
    final weeks = difference.inDays ~/ 7;
    return context.t(
      '$weeks week${weeks > 1 ? 's' : ''} ago',
      '$weeks tuần trước',
    );
  }

  if (difference.inDays > 0) {
    final days = difference.inDays;
    return context.t('$days day${days > 1 ? 's' : ''} ago', '$days ngày trước');
  }

  if (difference.inHours > 0) {
    final hours = difference.inHours;
    return context.t(
      '$hours hour${hours > 1 ? 's' : ''} ago',
      '$hours giờ trước',
    );
  }

  if (difference.inMinutes > 0) {
    final minutes = difference.inMinutes;
    return context.t(
      '$minutes minute${minutes > 1 ? 's' : ''} ago',
      '$minutes phút trước',
    );
  }

  return context.t('Just now', 'Vừa xong');
}

/// Helper function to get icon for notification type
IconData _getNotificationIcon(String type) {
  switch (type) {
    case 'ekyc_completed':
      return Icons.verified_user;
    case 'step3_completed':
      return Icons.assignment_turned_in;
    case 'step4_completed':
      return Icons.calculate;
    case 'step5_completed':
      return Icons.description;
    case 'loan_approved':
      return Icons.check_circle;
    case 'loan_rejected':
      return Icons.cancel;
    case 'credit_score_updated':
      return Icons.trending_up;
    case 'payment_reminder':
      return Icons.payment;
    case 'payment_success':
      return Icons.task_alt;
    default:
      return Icons.notifications;
  }
}
