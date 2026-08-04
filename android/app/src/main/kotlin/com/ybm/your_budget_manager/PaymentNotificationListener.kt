package com.ybm.your_budget_manager

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import io.flutter.plugin.common.MethodChannel
import java.util.regex.Pattern

// PRIVACY: This service processes payment notifications locally. No content is logged, stored, or transmitted.
class PaymentNotificationListener : NotificationListenerService() {

    companion object {
        var methodChannel: MethodChannel? = null

        val PAYMENT_PACKAGES: Set<String> = setOf(
            "com.google.android.apps.nfc.plugin.card.wallet",
            "com.google.android.apps.nfc.pay",
            "com.google.android.apps.walletnfcrel",
            "com.phonepe.app",
            "com.phonepe.app.business",
            "net.one97.paytm",
            "com.paytm.business",
            "com.amazon.mShop.android.shopping",
            "in.amazon.mShop.android.shopping",
            "com.cred.club",
            "com.whatsapp",
            "com.whatsapp.w4b",
            "in.org.npci.upiapp",
            "com.supermoney.app",
            "in.supermoney.app",
            "com.freecharge.android",
            "com.mobikwik_new",
            "com.csam.icici.bank.imobile",
            "com.sbi.upi",
            "com.sbt.App",
            "com.sbi.lotusintouch",
            "com.axis.mobile",
            "com.hdfcbank.payzapp",
            "com.snapwork.hdfc",
            "com.slicepay",
            "com.fifteen.fi",
            "com.epifi",
            "com.jupiter.money",
            "com.navi.navi",
            "com.pop.app"
        )

        fun getAppName(packageName: String): String {
            return when {
                packageName.contains("google") -> "Google Pay"
                packageName.contains("phonepe") -> "PhonePe"
                packageName.contains("paytm") -> "Paytm"
                packageName.contains("amazon") -> "Amazon Pay"
                packageName.contains("cred") -> "CRED"
                packageName.contains("whatsapp") -> "WhatsApp"
                packageName.contains("upiapp") || packageName.contains("npci") -> "BHIM UPI"
                packageName.contains("supermoney") -> "SuperMoney"
                packageName.contains("freecharge") -> "Freecharge"
                packageName.contains("mobikwik") -> "MobiKwik"
                packageName.contains("icici") -> "iMobile Pay"
                packageName.contains("sbi") || packageName.contains("sbt") -> "SBI Pay"
                packageName.contains("axis") -> "Axis Mobile"
                packageName.contains("payzapp") -> "PayZapp"
                packageName.contains("hdfc") -> "HDFC Bank"
                packageName.contains("slice") -> "Slice"
                packageName.contains("fi") -> "Fi Money"
                packageName.contains("jupiter") -> "Jupiter"
                packageName.contains("navi") -> "Navi UPI"
                packageName.contains("pop") -> "Pop UPI"
                else -> "Payment App"
            }
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        if (sbn == null) return
        val packageName = sbn.packageName ?: return

        // Filter by package name FIRST before any processing
        if (!PAYMENT_PACKAGES.contains(packageName)) {
            return
        }

        val notification = sbn.notification ?: return
        val extras = notification.extras ?: return

        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""
        val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString() ?: ""

        val combinedContent = "$title $text $bigText"
        if (combinedContent.trim().isEmpty()) return

        val amountPaise = parseAmountPaise(combinedContent)
        if (amountPaise <= 0L) return

        val type = determineType(combinedContent)
        val merchant = parseMerchant(combinedContent)
        val utr = parseUtr(combinedContent)
        val appName = getAppName(packageName)

        val payload = HashMap<String, Any?>().apply {
            put("packageName", packageName)
            put("appName", appName)
            put("title", title)
            put("text", text)
            put("amountPaise", amountPaise)
            put("merchant", merchant)
            put("type", type)
            put("utr", utr)
            put("timestamp", sbn.postTime)
        }

        methodChannel?.invokeMethod("onNotificationReceived", payload)
    }

    private fun determineType(content: String): String {
        val lower = content.lowercase()
        return if (lower.contains("received") || lower.contains("credited") || lower.contains("cashback") || lower.contains("got") || lower.contains("added")) {
            "income"
        } else {
            "expense"
        }
    }

    private fun parseAmountPaise(content: String): Long {
        val patterns = listOf(
            Pattern.compile("(?:Rs\\.?|INR|₹)\\s*([\\d,]+(?:\\.\\d{1,2})?)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("([\\d,]+(?:\\.\\d{1,2})?)\\s*(?:Rs\\.?|INR|₹)", Pattern.CASE_INSENSITIVE),
            Pattern.compile("(?:paid|sent|received|credited)\\s+(?:Rs\\.?|INR|₹)?\\s*([\\d,]+(?:\\.\\d{1,2})?)", Pattern.CASE_INSENSITIVE)
        )

        for (pattern in patterns) {
            val matcher = pattern.matcher(content)
            if (matcher.find()) {
                val matchStr = matcher.group(1)?.replace(",", "") ?: continue
                val doubleVal = matchStr.toDoubleOrNull()
                if (doubleVal != null && doubleVal > 0) {
                    return (doubleVal * 100).toLong()
                }
            }
        }
        return 0L
    }

    private fun parseMerchant(content: String): String? {
        val pattern = Pattern.compile("(?:to|paid to|sent to|from|received from|at|via)\\s+([A-Za-z0-9\\s&.\\-]{2,30})", Pattern.CASE_INSENSITIVE)
        val matcher = pattern.matcher(content)
        if (matcher.find()) {
            val candidate = matcher.group(1)?.trim()
            if (!candidate.isNullOrEmpty() && !candidate.lowercase().startsWith("rs") && !candidate.lowercase().startsWith("inr")) {
                return candidate
            }
        }
        return null
    }

    private fun parseUtr(content: String): String? {
        val pattern = Pattern.compile("(?:Ref|UTR|Txn|ID|Transaction ID)[:\\s]*([A-Za-z0-9]{8,22})", Pattern.CASE_INSENSITIVE)
        val matcher = pattern.matcher(content)
        if (matcher.find()) {
            return matcher.group(1)
        }
        return null
    }
}
