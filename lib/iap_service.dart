import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Why a purchase or restore did not go through, so the UI can say so.
enum IapProblem { storeUnavailable, purchaseFailed }

class IAPService {
  static const String productId = 'remove_ads_pro'; // 실제 스토어 등록 ID와 일치해야 함
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  Function(bool)? onPurchaseSuccess;

  /// Called when buying fails for a reason the user should hear about.
  /// A purchase the user cancels is not reported.
  void Function(IapProblem problem)? onProblem;

  IAPService() {
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        debugPrint('IAP Subscription Error: $error');
        onProblem?.call(IapProblem.purchaseFailed);
      },
    );
  }

  void _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // 결제 진행 중: Play 결제 화면이 안내함
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint('Purchase Error: ${purchaseDetails.error}');
        onProblem?.call(IapProblem.purchaseFailed);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // 결제 성공 또는 복원 성공
        if (purchaseDetails.productID == productId) {
          if (onPurchaseSuccess != null) {
            onPurchaseSuccess!(true);
          }
        }
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
      }
    }
  }

  Future<bool> isAvailable() async {
    return await _iap.isAvailable();
  }

  Future<void> buyNonConsumable() async {
    try {
      if (!await _iap.isAvailable()) {
        onProblem?.call(IapProblem.storeUnavailable);
        return;
      }
      final response = await _iap.queryProductDetails({productId});
      if (response.error != null || response.productDetails.isEmpty) {
        debugPrint(
          'Product not found: ${response.notFoundIDs} ${response.error}',
        );
        onProblem?.call(IapProblem.purchaseFailed);
        return;
      }
      final purchaseParam = PurchaseParam(
        productDetails: response.productDetails.first,
      );
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (error) {
      debugPrint('Purchase start failed: $error');
      onProblem?.call(IapProblem.purchaseFailed);
    }
  }

  Future<void> restorePurchases() async {
    try {
      if (!await _iap.isAvailable()) {
        onProblem?.call(IapProblem.storeUnavailable);
        return;
      }
      await _iap.restorePurchases();
    } catch (error) {
      debugPrint('Restore failed: $error');
      onProblem?.call(IapProblem.purchaseFailed);
    }
  }

  void dispose() {
    _subscription.cancel();
  }
}
