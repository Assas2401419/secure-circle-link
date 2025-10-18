import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'app.lovable.edb50425848c4c3c82ab3f39178b41c6',
  appName: 'GuardianLink',
  webDir: 'dist',
  server: {
    url: 'https://edb50425-848c-4c3c-82ab-3f39178b41c6.lovableproject.com?forceHideBadge=true',
    cleartext: true
  },
  plugins: {
    PushNotifications: {
      presentationOptions: ['badge', 'sound', 'alert']
    }
  }
};

export default config;
