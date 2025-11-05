import 'package:flutter/material.dart';
import 'package:logger/logger.dart'; // ✅ use your AppToast file
import 'package:pos_desktop/core/utils/toast_helper.dart';
import 'package:pos_desktop/domain/entities/subscription_entity.dart';
import 'package:pos_desktop/domain/usecases/add_subscription_usecase.dart';
import 'package:pos_desktop/domain/usecases/get_subscriptions_by_owner_usecase.dart';
import 'package:pos_desktop/domain/usecases/get_active_subscription_usecase.dart';
import 'package:pos_desktop/domain/usecases/update_subscription_status_usecase.dart';
import 'package:pos_desktop/domain/usecases/mark_expired_subscriptions_usecase.dart';

class SubscriptionManagementController extends ChangeNotifier {
  final AddSubscriptionUseCase addSubscriptionUseCase;
  final GetSubscriptionsByOwnerUseCase getSubscriptionsByOwnerUseCase;
  final GetActiveSubscriptionUseCase getActiveSubscriptionUseCase;
  final UpdateSubscriptionStatusUseCase updateSubscriptionStatusUseCase;
  final MarkExpiredSubscriptionsUseCase markExpiredSubscriptionsUseCase;

  final _logger = Logger();
  bool isLoading = false;
  List<SubscriptionEntity> ownerSubscriptions = [];
  SubscriptionEntity? activeSubscription;

  SubscriptionManagementController({
    required this.addSubscriptionUseCase,
    required this.getSubscriptionsByOwnerUseCase,
    required this.getActiveSubscriptionUseCase,
    required this.updateSubscriptionStatusUseCase,
    required this.markExpiredSubscriptionsUseCase,
  });

  // ======================================================
  // 🟢 Owner: Add subscription (after payment upload)
  // ======================================================
  Future<void> addSubscription(
    BuildContext context, {
    required String ownerId,
    required int planId,
    required String planName,
    required double amount,
    required String receiptImage,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final now = DateTime.now();
      final subscription = SubscriptionEntity(
        id: '',
        ownerId: ownerId,
        subscriptionPlanId: planId.toString(),
        subscriptionPlanName: planName,
        subscriptionAmount: amount,
        receiptImage: receiptImage,
        status: 'inactive', // pending admin approval
        paymentDate: now,
        subscriptionStartDate: now,
        subscriptionEndDate: now.add(const Duration(days: 30)),
      );

      await addSubscriptionUseCase(subscription);
      AppToast.show(
        context,
        message: 'Subscription submitted for approval',
        type: ToastType.success,
      );
      _logger.i('🧾 Subscription created for ownerId=$ownerId plan=$planName');
    } catch (e) {
      _logger.e('❌ Failed to add subscription: $e');
      AppToast.show(
        context,
        message: 'Failed to add subscription',
        type: ToastType.error,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // 🟣 Owner/Admin: Get all subscriptions for owner
  // ======================================================
  Future<void> loadSubscriptions(String ownerId) async {
    try {
      isLoading = true;
      notifyListeners();

      final subs = await getSubscriptionsByOwnerUseCase(ownerId);
      ownerSubscriptions = subs;
      _logger.i('📦 Loaded ${subs.length} subscriptions for ownerId=$ownerId');
    } catch (e) {
      _logger.e('❌ Failed to load subscriptions: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // 🟢 Owner/Admin: Get active subscription
  // ======================================================
  Future<void> loadActiveSubscription(String ownerId) async {
    try {
      final sub = await getActiveSubscriptionUseCase(ownerId);
      activeSubscription = sub;
      if (sub != null) {
        _logger.i('✅ Active subscription found: ${sub.subscriptionPlanName}');
      } else {
        _logger.w('⚠️ No active subscription for ownerId=$ownerId');
      }
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Failed to load active subscription: $e');
    }
  }

  // ======================================================
  // 🟡 Admin: Approve or Reject subscription
  // ======================================================
  Future<void> updateSubscriptionStatus(
    BuildContext context, {
    required String subscriptionId,
    required String status, // 'active' | 'rejected'
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await updateSubscriptionStatusUseCase(subscriptionId, status);
      _logger.i('🔄 Subscription $subscriptionId updated to $status');

      AppToast.show(
        context,
        message: status == 'active'
            ? 'Subscription activated'
            : 'Subscription rejected',
        type: status == 'active' ? ToastType.success : ToastType.warning,
      );
    } catch (e) {
      _logger.e('❌ Failed to update subscription status: $e');
      AppToast.show(
        context,
        message: 'Failed to update status',
        type: ToastType.error,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // 🔄 System: Mark expired subscriptions
  // ======================================================
  Future<void> markExpiredSubscriptions() async {
    try {
      await markExpiredSubscriptionsUseCase();
      _logger.i('⌛ Expired subscriptions marked successfully');
    } catch (e) {
      _logger.e('❌ Failed to mark expired subscriptions: $e');
    }
  }

  // ======================================================
  // 🧹 Clear state
  // ======================================================
  void clear() {
    ownerSubscriptions = [];
    activeSubscription = null;
    notifyListeners();
  }
}
