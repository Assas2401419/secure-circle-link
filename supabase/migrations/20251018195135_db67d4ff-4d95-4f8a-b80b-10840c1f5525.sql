-- Create location_logs table for tracking user location history
CREATE TABLE public.location_logs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  accuracy DECIMAL(10, 2),
  timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  session_id UUID,
  CONSTRAINT fk_location_user FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE
);

-- Create index for faster location queries
CREATE INDEX idx_location_logs_user_timestamp ON public.location_logs(user_id, timestamp DESC);
CREATE INDEX idx_location_logs_session ON public.location_logs(session_id);

-- Enable RLS on location_logs
ALTER TABLE public.location_logs ENABLE ROW LEVEL SECURITY;

-- RLS policies for location_logs
CREATE POLICY "Users can view own location logs"
  ON public.location_logs
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own location logs"
  ON public.location_logs
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own location logs"
  ON public.location_logs
  FOR DELETE
  USING (auth.uid() = user_id);

-- Create monitoring_sessions table for tracking active safety monitoring
CREATE TABLE public.monitoring_sessions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  session_type TEXT NOT NULL CHECK (session_type IN ('companion', 'smart_detection', 'manual')),
  started_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  ended_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN NOT NULL DEFAULT true,
  companion_share_token TEXT UNIQUE,
  CONSTRAINT fk_session_user FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE
);

-- Create index for active sessions
CREATE INDEX idx_monitoring_sessions_user_active ON public.monitoring_sessions(user_id, is_active);
CREATE INDEX idx_monitoring_sessions_token ON public.monitoring_sessions(companion_share_token) WHERE companion_share_token IS NOT NULL;

-- Enable RLS on monitoring_sessions
ALTER TABLE public.monitoring_sessions ENABLE ROW LEVEL SECURITY;

-- RLS policies for monitoring_sessions
CREATE POLICY "Users can view own sessions"
  ON public.monitoring_sessions
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own sessions"
  ON public.monitoring_sessions
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own sessions"
  ON public.monitoring_sessions
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Create alerts table for tracking emergency alerts
CREATE TABLE public.alerts (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  trigger_method TEXT NOT NULL CHECK (trigger_method IN ('sos_button', 'voice_command', 'smart_detection', 'manual')),
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  triggered_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  resolved_at TIMESTAMP WITH TIME ZONE,
  is_resolved BOOLEAN NOT NULL DEFAULT false,
  photo_url TEXT,
  notes TEXT,
  CONSTRAINT fk_alert_user FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE
);

-- Create index for alert queries
CREATE INDEX idx_alerts_user_triggered ON public.alerts(user_id, triggered_at DESC);
CREATE INDEX idx_alerts_resolved ON public.alerts(is_resolved, triggered_at DESC);

-- Enable RLS on alerts
ALTER TABLE public.alerts ENABLE ROW LEVEL SECURITY;

-- RLS policies for alerts
CREATE POLICY "Users can view own alerts"
  ON public.alerts
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own alerts"
  ON public.alerts
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own alerts"
  ON public.alerts
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Create alert_notifications table to track which contacts were notified
CREATE TABLE public.alert_notifications (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  alert_id UUID NOT NULL,
  contact_id UUID NOT NULL,
  notification_type TEXT NOT NULL CHECK (notification_type IN ('push', 'sms', 'whatsapp', 'email')),
  sent_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  delivery_status TEXT CHECK (delivery_status IN ('pending', 'sent', 'delivered', 'failed')),
  error_message TEXT,
  CONSTRAINT fk_notification_alert FOREIGN KEY (alert_id) REFERENCES public.alerts(id) ON DELETE CASCADE,
  CONSTRAINT fk_notification_contact FOREIGN KEY (contact_id) REFERENCES public.emergency_contacts(id) ON DELETE CASCADE
);

-- Create index for notification tracking
CREATE INDEX idx_alert_notifications_alert ON public.alert_notifications(alert_id);
CREATE INDEX idx_alert_notifications_status ON public.alert_notifications(delivery_status, sent_at DESC);

-- Enable RLS on alert_notifications
ALTER TABLE public.alert_notifications ENABLE ROW LEVEL SECURITY;

-- RLS policies for alert_notifications (users can view notifications for their own alerts)
CREATE POLICY "Users can view notifications for own alerts"
  ON public.alert_notifications
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.alerts
      WHERE alerts.id = alert_notifications.alert_id
      AND alerts.user_id = auth.uid()
    )
  );

-- Enable realtime for critical tables
ALTER PUBLICATION supabase_realtime ADD TABLE public.alerts;
ALTER PUBLICATION supabase_realtime ADD TABLE public.location_logs;
ALTER PUBLICATION supabase_realtime ADD TABLE public.monitoring_sessions;