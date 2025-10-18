import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/integrations/supabase/client';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Shield, LogOut, Users, AlertCircle } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';

const Home = () => {
  const navigate = useNavigate();
  const { user } = useAuth();
  const { toast } = useToast();

  const handleLogout = async () => {
    await supabase.auth.signOut();
    navigate('/auth');
  };

  const handleSOS = () => {
    toast({
      title: 'SOS Triggered!',
      description: 'Emergency alert sent to your contacts.',
    });
  };

  return (
    <div className="flex min-h-screen flex-col bg-gradient-to-br from-background via-background to-accent/20">
      {/* Header */}
      <header className="border-b bg-card/50 backdrop-blur-sm">
        <div className="container mx-auto flex items-center justify-between p-4">
          <div className="flex items-center gap-2">
            <Shield className="h-6 w-6 text-primary" />
            <h1 className="text-xl font-bold">GuardianLink</h1>
          </div>
          <Button variant="ghost" size="icon" onClick={handleLogout}>
            <LogOut className="h-5 w-5" />
          </Button>
        </div>
      </header>

      {/* Main Content */}
      <main className="container mx-auto flex flex-1 flex-col items-center justify-center p-4">
        <div className="w-full max-w-md space-y-6">
          {/* SOS Button */}
          <Card className="border-destructive bg-destructive/10 p-8 text-center">
            <button
              onClick={handleSOS}
              className="mx-auto flex h-48 w-48 items-center justify-center rounded-full bg-destructive transition-transform active:scale-95"
            >
              <AlertCircle className="h-24 w-24 text-destructive-foreground" />
            </button>
            <p className="mt-4 text-lg font-semibold text-destructive">
              Emergency SOS
            </p>
            <p className="text-sm text-muted-foreground">
              Press and hold to trigger alert
            </p>
          </Card>

          {/* Quick Actions */}
          <div className="grid gap-4">
            <Button
              variant="outline"
              className="justify-start"
              onClick={() => navigate('/contacts')}
            >
              <Users className="mr-2 h-5 w-5" />
              Emergency Contacts
            </Button>
          </div>
        </div>
      </main>
    </div>
  );
};

export default Home;
