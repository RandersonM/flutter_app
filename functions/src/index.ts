import {onSchedule} from "firebase-functions/v2/scheduler";
import {onCall, onRequest, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK
admin.initializeApp();

// References for Firestore and Firebase Messaging
const db = admin.firestore();
const messaging = admin.messaging();

// ============================================================================
// FUNCTION 1: NAMI MONTHLY NOTIFICATION (LAST DAY OF MONTH)
// ============================================================================
// Schedule: "0 9 28-31 * *" - Runs at 9am on days 28-31 of each month
// Timezone: America/Sao_Paulo (Brasília time)
// Verifies if it's really the last day of the month before sending
export const sendNamiMonthlyNotification = onSchedule({
  schedule: "0 9 28-31 * *", // Minute 0, Hour 9, Days 28-31, Every month, Every day of week
  timeZone: "America/Sao_Paulo",
}, async () => {
  try {
    // Check if it's really the last day of the month
    const now = new Date();
    const tomorrow = new Date(now);
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    // If tomorrow is day 1, then today is the last day of the month
    if (tomorrow.getDate() !== 1) {
      console.log("Not the last day of the month, skipping Nami notification");
      return;
    }

    console.log("Sending Nami monthly notification...");

    // Get all FCM tokens from users
    const tokensSnapshot = await db.collection("user_tokens").get();
    const tokens: string[] = [];

    tokensSnapshot.forEach((doc) => {
      const data = doc.data();
      if (data.fcmToken) {
        tokens.push(data.fcmToken);
      }
    });

    if (tokens.length === 0) {
      console.log("No tokens found");
      return;
    }

    // Configure notification message
    const message = {
      notification: {
        title: "💰 Relatório Mensal da Nami",
        body: "Chegou a hora de revisar suas finanças do mês! Veja seu relatório completo e mude o seu futuro.",
      },
      data: {
        type: "nami_monthly_report", // Type to identify in app
        screen: "nami_finances", // Screen to open in app
        timestamp: Date.now().toString(),
      },
      android: {
        notification: {
          channelId: "nami_channel", // Specific channel for Android
          priority: "high" as const,
          defaultSound: true,
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    // Send notification to all tokens
    const response = await messaging.sendEachForMulticast({
      tokens,
      ...message,
    });

    console.log(`Nami notification sent: ${response.successCount}/${tokens.length} successes`);

    // Remove invalid tokens if there are failures
    if (response.failureCount > 0) {
      const failedTokens: string[] = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          failedTokens.push(tokens[idx]);
          console.log(`Failed to send to token: ${tokens[idx]}`);
        }
      });

      if (failedTokens.length > 0) {
        await removeInvalidTokens(failedTokens);
      }
    }
  } catch (error) {
    console.error("Error sending Nami notification:", error);
  }
});

// ============================================================================
// FUNCTION 2: ZORO WORKOUT NOTIFICATION (MONDAY TO SATURDAY AT 18:00)
// ============================================================================
// Schedule: "0 18 * * 1-6" - Runs at 6pm Monday to Saturday
// Timezone: America/Sao_Paulo (Brasília time)
export const sendZoroWorkoutNotification = onSchedule({
  schedule: "0 18 * * 1-6", // Minute 0, Hour 18, Every day, Every month, Monday(1) to Saturday(6)
  timeZone: "America/Sao_Paulo",
}, async () => {
  try {
    console.log("Sending Zoro notification...");

    // Get all FCM tokens from users
    const tokensSnapshot = await db.collection("user_tokens").get();
    const tokens: string[] = [];

    tokensSnapshot.forEach((doc) => {
      const data = doc.data();
      if (data.fcmToken) {
        tokens.push(data.fcmToken);
      }
    });

    if (tokens.length === 0) {
      console.log("No tokens found");
      return;
    }

    const zoroMessages = [
      {
        title: "⚔️ Hora de Treinar",
        body: "Não vai ficar mais forte parado aí. Pegue sua espada e venha treinar comigo!",
      },
      {
        title: "🏋️‍♂️ Mais Forte que Ontem",
        body: "Se quer me alcançar, vai ter que suar muito. Levanta e começa agora!",
      },
      {
        title: "💪 Não Existe Descanso",
        body: "Enquanto você pensa em descansar, eu já estou treinando. Vai ficar para trás?",
      },
      {
        title: "🏃‍♂️ Corra como se fosse uma missão",
        body: "Se não correr hoje, vai perder o fôlego na próxima batalha!",
      },
      {
        title: "🥇 O Mais Forte dos Mares",
        body: "Se quer ser o melhor espadachim, comece treinando o corpo agora!",
      },
    ];

    // Select a random message
    const randomMessage = zoroMessages[Math.floor(Math.random() * zoroMessages.length)];

    // Configure notification message
    const message = {
      notification: {
        title: randomMessage.title,
        body: randomMessage.body,
      },
      data: {
        type: "zoro_workout", // Type to identify in app
        screen: "zoro_workout", // Screen to open in app
        timestamp: Date.now().toString(),
      },
      android: {
        notification: {
          channelId: "zoro_channel", // Specific channel for Android
          priority: "high" as const,
          defaultSound: true,
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    // Send notification to all tokens
    const response = await messaging.sendEachForMulticast({
      tokens,
      ...message,
    });

    console.log(`Zoro notification sent: ${response.successCount}/${tokens.length} successes`);
    console.log(`Message sent: ${randomMessage.title}`);

    // Remove invalid tokens if there are failures
    if (response.failureCount > 0) {
      const failedTokens: string[] = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          failedTokens.push(tokens[idx]);
          console.log(`Failed to send to token: ${tokens[idx]}`);
        }
      });

      if (failedTokens.length > 0) {
        await removeInvalidTokens(failedTokens);
      }
    }
  } catch (error) {
    console.error("Error sending Zoro notification:", error);
  }
});

// ============================================================================
// FUNCTION 3: SANJI COOKING NOTIFICATION (EVERY DAY AT 12:00)
// ============================================================================
// Schedule: "0 12 * * *" - Runs at 12pm every day
// Timezone: America/Sao_Paulo (Brasília time)
export const sendSanjiCookingNotification = onSchedule({
  schedule: "0 12 * * *", // Minute 0, Hour 12, Every day, Every month, Every day of week
  timeZone: "America/Sao_Paulo",
}, async () => {
  try {
    console.log("Sending Sanji notification...");

    // Get all FCM tokens from users
    const tokensSnapshot = await db.collection("user_tokens").get();
    const tokens: string[] = [];

    tokensSnapshot.forEach((doc) => {
      const data = doc.data();
      if (data.fcmToken) {
        tokens.push(data.fcmToken);
      }
    });

    if (tokens.length === 0) {
      console.log("No tokens found");
      return;
    }

    // Array of messages in Sanji's style
    const sanjiMessages = [
      {
        title: "👨‍🍳 O Chef Sanji Chama!",
        body: "Uma boa refeição é tão importante quanto vencer uma batalha. Vamos cozinhar algo incrível!",
      },
      {
        title: "🍽️ Hora de Encantar o Paladar",
        body: "Não é só comer, é saborear a vida. Venha preparar um prato digno de um verdadeiro chef!",
      },
      {
        title: "🥗 Força Vem de Boa Alimentação",
        body: "Um corpo forte precisa de combustível de qualidade. Vamos preparar algo nutritivo agora!",
      },
      {
        title: "🥘 Culinária que Alimenta a Alma",
        body: "Comer bem é amar a si mesmo. Vamos preparar um prato que aqueça o coração!",
      },
        {
        title: "🥦 Lembrete do Chef",
        body: "Não esqueça: equilíbrio é a chave! Mantenha sua dieta saudável para ter energia todos os dias.",
      },
      {
        title: "🍲 Receita Vital do Dia",
        body: "Alguns pratos não são apenas deliciosos, mas essenciais para sua saúde. Vamos preparar um deles agora!",
      }
    ];


    // Select a random message
    const randomMessage = sanjiMessages[Math.floor(Math.random() * sanjiMessages.length)];

    // Configure notification message
    const message = {
      notification: {
        title: randomMessage.title,
        body: randomMessage.body,
      },
      data: {
        type: "sanji_cooking", // Type to identify in app
        screen: "sanji_cooking", // Screen to open in app
        timestamp: Date.now().toString(),
      },
      android: {
        notification: {
          channelId: "sanji_channel", // Specific channel for Android
          priority: "high" as const,
          defaultSound: true,
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    // Send notification to all tokens
    const response = await messaging.sendEachForMulticast({
      tokens,
      ...message,
    });

    console.log(`Sanji notification sent: ${response.successCount}/${tokens.length} successes`);
    console.log(`Message sent: ${randomMessage.title}`);

    // Remove invalid tokens if there are failures
    if (response.failureCount > 0) {
      const failedTokens: string[] = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          failedTokens.push(tokens[idx]);
          console.log(`Failed to send to token: ${tokens[idx]}`);
        }
      });

      if (failedTokens.length > 0) {
        await removeInvalidTokens(failedTokens);
      }
    }
  } catch (error) {
    console.error("Error sending Sanji notification:", error);
  }
});

// ============================================================================
// FUNCTION 4: CUSTOM NOTIFICATION (CALLED BY APP)
// ============================================================================
// This function is called by the Flutter app to send custom notifications
// Can send to all users or specific users
export const sendCustomNotification = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be authenticated");
  }

  if (!request.auth.token.admin) {
    throw new HttpsError("permission-denied", "Admin access required");
  }

  try {
    const {title, body, type, screen, userIds} = request.data as {
      title: string;
      body: string;
      type?: string;
      screen?: string;
      userIds?: string[];
    };

    if (!title || !body) {
      throw new Error("Title and body are required");
    }

    const tokens: string[] = [];

    // If userIds is provided, send only to those users
    if (userIds && userIds.length > 0) {
      const userTokensSnapshot = await db.collection("user_tokens")
        .where(admin.firestore.FieldPath.documentId(), "in", userIds)
        .get();

      userTokensSnapshot.forEach((doc) => {
        const userData = doc.data();
        if (userData.fcmToken) {
          tokens.push(userData.fcmToken);
        }
      });
    } else {
      // Otherwise, send to all users
      const allTokensSnapshot = await db.collection("user_tokens").get();

      allTokensSnapshot.forEach((doc) => {
        const userData = doc.data();
        if (userData.fcmToken) {
          tokens.push(userData.fcmToken);
        }
      });
    }

    if (tokens.length === 0) {
      return {success: false, message: "No tokens found"};
    }

    // Configure notification message
    const message = {
      notification: {
        title,
        body,
      },
      data: {
        type: type || "custom",
        screen: screen || "home",
        timestamp: Date.now().toString(),
      },
      android: {
        notification: {
          channelId: "default_channel",
          priority: "high" as const,
          defaultSound: true,
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    // Send notification
    const response = await messaging.sendEachForMulticast({
      tokens,
      ...message,
    });

    // Return result
    return {
      success: true,
      sent: response.successCount,
      total: tokens.length,
      failed: response.failureCount,
    };
  } catch (error) {
    console.error("Error sending custom notification:", error);
    throw new Error("Internal server error");
  }
});

// ============================================================================
// HELPER FUNCTION: REMOVE INVALID TOKENS
// ============================================================================
// Removes FCM tokens that are no longer valid from Firestore
async function removeInvalidTokens(failedTokens: string[]) {
  try {
    const batch = db.batch();

    for (const token of failedTokens) {
      const tokenDocs = await db.collection("user_tokens")
        .where("fcmToken", "==", token)
        .get();

      tokenDocs.forEach((doc) => {
        batch.delete(doc.ref);
      });
    }

    await batch.commit();
    console.log(`Removed ${failedTokens.length} invalid tokens`);
  } catch (error) {
    console.error("Error removing invalid tokens:", error);
  }
}

// ============================================================================
// FUNCTION 5: NOTIFICATION TEST (HTTP REQUEST)
// ============================================================================
// Function to test notifications via HTTP request
// Useful for manual testing and debugging
export const testNotification = onRequest(async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith("Bearer ")) {
      res.status(401).json({error: "Unauthorized"});
      return;
    }

    const idToken = authHeader.split("Bearer ")[1];
    let decodedToken: admin.auth.DecodedIdToken;
    try {
      decodedToken = await admin.auth().verifyIdToken(idToken);
    } catch {
      res.status(401).json({error: "Invalid token"});
      return;
    }

    if (!decodedToken.admin) {
      res.status(403).json({error: "Forbidden: admin access required"});
      return;
    }

    const {title = "Test", body = "This is a test notification"} = req.body;

    // Get only 5 tokens for testing
    const tokensSnapshot = await db.collection("user_tokens").limit(5).get();
    const tokens: string[] = [];

    tokensSnapshot.forEach((doc) => {
      const data = doc.data();
      if (data.fcmToken) {
        tokens.push(data.fcmToken);
      }
    });

    if (tokens.length === 0) {
      res.status(400).json({error: "No tokens found"});
      return;
    }

    // Configure test message
    const message = {
      notification: {
        title,
        body,
      },
      data: {
        type: "test",
        screen: "home",
        timestamp: Date.now().toString(),
      },
    };

    // Send test notification
    const response = await messaging.sendEachForMulticast({
      tokens,
      ...message,
    });

    // Return result
    res.json({
      success: true,
      sent: response.successCount,
      total: tokens.length,
      failed: response.failureCount,
    });
  } catch (error) {
    console.error("Error in notification test:", error);
    res.status(500).json({error: "Internal server error"});
  }
});
