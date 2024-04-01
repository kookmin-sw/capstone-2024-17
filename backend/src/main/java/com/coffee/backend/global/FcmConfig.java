package com.coffee.backend.global;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;
import java.io.IOException;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

@Configuration
public class FcmConfig {
    private static final String FIREBASE_CONFIG_PATH = "firebase/firebase_service_key.json";

    @Bean
    public FirebaseMessaging firebaseMessaging() throws IOException {
        FirebaseApp firebaseApp = initFirebaseApp();
        return FirebaseMessaging.getInstance(firebaseApp);
        }

    private FirebaseApp initFirebaseApp() throws IOException {
        FirebaseApp existingApp = findExistingFirebaseApp();
        return (existingApp != null) ? existingApp : createNewFirebaseApp();
    }

    private FirebaseApp findExistingFirebaseApp() {
        for (FirebaseApp app : FirebaseApp.getApps()) {
            if (FirebaseApp.DEFAULT_APP_NAME.equals(app.getName())) {
                return app;
            }
        }
        return null;
    }

    private FirebaseApp createNewFirebaseApp() throws IOException {
        FirebaseOptions options = FirebaseOptions.builder()
                .setCredentials(GoogleCredentials.fromStream(new ClassPathResource(FIREBASE_CONFIG_PATH).getInputStream()))
                .build();

        return FirebaseApp.initializeApp(options);
    }
}
