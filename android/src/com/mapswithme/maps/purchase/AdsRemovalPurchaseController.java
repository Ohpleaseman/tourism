package com.mapswithme.maps.purchase;

import android.app.Activity;
import android.support.annotation.NonNull;
import android.text.TextUtils;

import com.android.billingclient.api.Purchase;
import com.mapswithme.maps.Framework;
import com.mapswithme.maps.PrivateVariables;
import com.mapswithme.util.ConnectionState;
import com.mapswithme.util.log.Logger;
import com.mapswithme.util.log.LoggerFactory;
import com.mapswithme.util.statistics.Statistics;

import java.util.List;

class AdsRemovalPurchaseController extends AbstractPurchaseController<ValidationCallback,
    PlayStoreBillingCallback, PurchaseCallback>
{
  private static final Logger LOGGER = LoggerFactory.INSTANCE.getLogger(LoggerFactory.Type.BILLING);
  private static final String TAG = AdsRemovalPurchaseController.class.getSimpleName();
  @NonNull
  private final ValidationCallback mValidationCallback = new AdValidationCallbackImpl();
  @NonNull
  private final PlayStoreBillingCallback mBillingCallback = new PlayStoreBillingCallbackImpl();

  AdsRemovalPurchaseController(@NonNull PurchaseValidator<ValidationCallback> validator,
                               @NonNull BillingManager<PlayStoreBillingCallback> billingManager,
                               @NonNull String... productIds)
  {
    super(validator, billingManager, productIds);
  }

  @Override
  void onInitialize(@NonNull Activity activity)
  {
    getValidator().addCallback(mValidationCallback);
    getBillingManager().addCallback(mBillingCallback);
    getBillingManager().queryExistingPurchases();
  }

  @Override
  void onDestroy()
  {
    getValidator().removeCallback();
    getBillingManager().removeCallback(mBillingCallback);
  }

  @Override
  public void queryPurchaseDetails()
  {
    getBillingManager().queryProductDetails(getProductIds());
  }

  private class AdValidationCallbackImpl implements ValidationCallback
  {

    @Override
    public void onValidate(@NonNull ValidationStatus status)
    {
      LOGGER.i(TAG, "Validation status of 'ads removal': " + status);
      if (status == ValidationStatus.VERIFIED)
        Statistics.INSTANCE.trackEvent(Statistics.EventName.INAPP_PURCHASE_VALIDATION_SUCCESS);
      else
        Statistics.INSTANCE.trackPurchaseValidationError(status);

      final boolean activateSubscription = status != ValidationStatus.NOT_VERIFIED;
      final boolean hasActiveSubscription = Framework.nativeHasActiveRemoveAdsSubscription();
      if (!hasActiveSubscription && activateSubscription)
      {
        LOGGER.i(TAG, "Ads removal subscription activated");
        Statistics.INSTANCE.trackPurchaseProductDelivered(PrivateVariables.adsRemovalVendor());
      }
      else if (hasActiveSubscription && !activateSubscription)
      {
        LOGGER.i(TAG, "Ads removal subscription deactivated");
      }

      Framework.nativeSetActiveRemoveAdsSubscription(activateSubscription);

      if (getUiCallback() != null)
        getUiCallback().onValidationFinish(activateSubscription);
    }
  }

  private class PlayStoreBillingCallbackImpl extends AbstractPlayStoreBillingCallback
  {
    @Override
    void validate(@NonNull String purchaseData)
    {
      getValidator().validate(PrivateVariables.adsRemovalServerId(),
                              PrivateVariables.adsRemovalVendor(), purchaseData);
    }

    @Override
    public void onPurchasesLoaded(@NonNull List<Purchase> purchases)
    {
      String purchaseData = null;
      String productId = null;
      Purchase target = findTargetPurchase(purchases);
      if (target != null)
      {
        purchaseData = target.getOriginalJson();
        productId = target.getSku();
      }

      if (TextUtils.isEmpty(purchaseData))
      {
        LOGGER.i(TAG, "Existing purchase data for 'ads removal' not found");
        if (Framework.nativeHasActiveRemoveAdsSubscription())
        {
          LOGGER.i(TAG, "Ads removal subscription deactivated");
          Framework.nativeSetActiveRemoveAdsSubscription(false);
        }
        return;
      }

      if (!ConnectionState.isWifiConnected())
      {
        LOGGER.i(TAG, "Validation postponed, connection not WI-FI.");
        return;
      }

      LOGGER.i(TAG, "Validating existing purchase data for '" + productId + "'...");
      getValidator().validate(PrivateVariables.adsRemovalServerId(),
                              PrivateVariables.adsRemovalVendor(), purchaseData);
    }
  }
}
