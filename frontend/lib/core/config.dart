/// Where MagnaVita accounts live (Supabase). The URL and publishable key are
/// meant to be public: Row Level Security protects each person's data.
const supabaseUrl = 'https://islckdvxqfrqmsvqbido.supabase.co';
const supabasePublishableKey = 'sb_publishable_cTeLzXlMf2U7W5Ii-OAWqg_qGnVvGnX';

/// Google sign-in: the *Web* OAuth client ID from Google Cloud (also entered
/// in Supabase → Authentication → Providers → Google). Empty until set up;
/// the Google button then explains it isn't available yet.
const googleWebClientId = ''; // e.g. '1234-abc.apps.googleusercontent.com'
