const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

exports.sendSmsOnStatusChange = functions.firestore
    .document("appointments/{appointmentId}")
    .onUpdate(async (change, context) => {
      const newValue = change.after.data();
      const previousValue = change.before.data();

      // We only want to send an SMS when the status changes
      if (newValue.status === previousValue.status) {
        return null;
      }
      
      const customerName = newValue.name;
      const customerPhone = newValue.phone;
      const appointmentStatus = newValue.status;

      let message = "";
      if (appointmentStatus === "Tasdiqlandi") {
        message = `Hurmatli ${customerName}, sizning sartaroshxonaga navbatingiz tasdiqlandi.`;
      } else if (appointmentStatus === "Rad etildi") {
        message = `Hurmatli ${customerName}, afsuski, sizning sartaroshxonaga navbatingiz rad etildi. Iltimos, boshqa vaqtni tanlang.`;
      } else {
        // We don't send SMS for 'pending' or other statuses
        return null;
      }
      
      // Eskiz.uz API credentials (REPLACE with your actual credentials)
      const ESKIZ_EMAIL = "YOUR_ESKIZ_EMAIL";
      const ESKIZ_KEY = "YOUR_ESKIZ_API_KEY";
      const ESKIZ_TOKEN_URL = "http://notify.eskiz.uz/api/auth/login";
      const ESKIZ_SMS_URL = "http://notify.eskiz.uz/api/message/sms/send";

      try {
        // 1. Get auth token from Eskiz.uz
        const tokenResponse = await axios.post(ESKIZ_TOKEN_URL, {
            email: ESKIZ_EMAIL,
            password: ESKIZ_KEY
        });
        
        const token = tokenResponse.data.data.token;

        if (!token) {
            functions.logger.error("Could not get Eskiz.uz auth token.");
            return null;
        }

        // 2. Send SMS
        const smsResponse = await axios.post(ESKIZ_SMS_URL, {
            mobile_phone: customerPhone,
            message: message,
            from: "4546", // Use your registered sender ID
        }, {
            headers: {
                "Authorization": `Bearer ${token}`
            }
        });
        
        functions.logger.info(`SMS sent successfully to ${customerPhone}`, smsResponse.data);
        return null;

      } catch (error) {
        functions.logger.error("Error sending SMS via Eskiz.uz:", error);
        return null;
      }
    }); 