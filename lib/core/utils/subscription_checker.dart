import 'package:pos_desktop/data/local/dao/owner_dao.dart';
import 'package:logger/logger.dart';
import 'package:pos_desktop/data/models/owner_model.dart';

class SubscriptionChecker {
  final OwnerDao _ownerDao;
  final _logger = Logger();

  SubscriptionChecker(this._ownerDao);

  /// ✅ Check and deactivate expired subscriptions
  Future<void> checkAndDeactivateExpiredSubscriptions() async {
    try {
      final expiredCount = await _ownerDao.deactivateExpiredSubscriptions();

      if (expiredCount > 0) {
        _logger.i('✅ Deactivated $expiredCount expired subscriptions');
      } else {
        _logger.i('✅ No expired subscriptions found');
      }
    } catch (e) {
      _logger.e('❌ Error checking expired subscriptions: $e');
    }
  }

  /// ✅ Get expiring subscriptions (for notification alerts, admin dashboard, etc.)
  Future<List<Map<String, dynamic>>> getExpiringSubscriptions() async {
    try {
      final List<OwnerModel> expiringOwners = await _ownerDao
          .getOwnersWithExpiringSubscriptions();

      return expiringOwners.map((owner) {
        final endDateStr = owner.subscriptionEndDate;
        final endDate = endDateStr != null
            ? DateTime.tryParse(endDateStr)
            : null;

        return {
          'ownerId': owner.id,
          'ownerName': owner.ownerName,
          'email': owner.email,
          'subscriptionEndDate': endDateStr ?? 'N/A',
          'daysRemaining': _calculateDaysRemaining(endDate),
        };
      }).toList();
    } catch (e) {
      _logger.e('❌ Error getting expiring subscriptions: $e');
      return [];
    }
  }

  /// ✅ Safe days remaining calculator
  int _calculateDaysRemaining(DateTime? endDate) {
    if (endDate == null) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }
}
