-- ==============================================================================
-- ROOMSYNC SUPABASE POSTGRESQL DATABASE SCHEMA & REALTIME SETUP
-- ==============================================================================

-- 1. PROFILES TABLE (Linked with Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  name TEXT NOT NULL,
  age INT NOT NULL DEFAULT 25,
  gender TEXT DEFAULT 'Not specified',
  occupation TEXT DEFAULT '',
  bio TEXT DEFAULT '',
  avatar_url TEXT DEFAULT '',
  image_urls TEXT[] DEFAULT '{}',
  budget NUMERIC(10, 2) NOT NULL DEFAULT 1500.0,
  location TEXT NOT NULL DEFAULT 'New York, NY',
  preferred_locations TEXT[] DEFAULT '{}',
  sleep_start TEXT NOT NULL DEFAULT '23:00',
  sleep_end TEXT NOT NULL DEFAULT '07:00',
  cleanliness_score INT NOT NULL DEFAULT 4 CHECK (cleanliness_score >= 1 AND cleanliness_score <= 5),
  smoking TEXT NOT NULL DEFAULT 'nonSmoker',
  pets TEXT NOT NULL DEFAULT 'petFriendly',
  is_verified BOOLEAN NOT NULL DEFAULT FALSE,
  habits JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. MATCHES TABLE
CREATE TABLE IF NOT EXISTS public.matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_1_id UUID NOT NULL REFERENCES public.profiles(user_id) ON DELETE CASCADE,
  user_2_id UUID NOT NULL REFERENCES public.profiles(user_id) ON DELETE CASCADE,
  is_mutual BOOLEAN NOT NULL DEFAULT FALSE,
  compatibility_score NUMERIC(5, 2) DEFAULT 0.0,
  score_breakdown JSONB DEFAULT '{}',
  last_message TEXT,
  last_message_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_1_id, user_2_id)
);

-- 3. MESSAGES TABLE
CREATE TABLE IF NOT EXISTS public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID NOT NULL REFERENCES public.matches(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES public.profiles(user_id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES public.profiles(user_id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  message_type TEXT NOT NULL DEFAULT 'text',
  meetup_details JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Enable Supabase Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.matches;

-- 5. APARTMENTS TABLE
CREATE TABLE IF NOT EXISTS public.apartments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  host_user_id UUID NOT NULL REFERENCES public.profiles(user_id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  neighborhood TEXT NOT NULL,
  city TEXT NOT NULL DEFAULT 'New York, NY',
  monthly_rent NUMERIC(10, 2) NOT NULL,
  bedrooms INT NOT NULL DEFAULT 2,
  bathrooms INT NOT NULL DEFAULT 1,
  is_furnished BOOLEAN DEFAULT FALSE,
  bills_included BOOLEAN DEFAULT FALSE,
  available_from TIMESTAMPTZ DEFAULT NOW(),
  amenities TEXT[] DEFAULT '{}',
  image_urls TEXT[] DEFAULT '{}',
  description TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Row Level Security (RLS) Configuration
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.apartments ENABLE ROW LEVEL SECURITY;

-- Profiles Policies
CREATE POLICY "Public profiles are readable by authenticated users"
  ON public.profiles FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Users can insert their own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = user_id);

-- Matches Policies
CREATE POLICY "Users can view matches they participate in"
  ON public.matches FOR SELECT
  USING (auth.uid() = user_1_id OR auth.uid() = user_2_id);

CREATE POLICY "Users can create matches involving themselves"
  ON public.matches FOR INSERT
  WITH CHECK (auth.uid() = user_1_id OR auth.uid() = user_2_id);

CREATE POLICY "Users can update matches involving themselves"
  ON public.matches FOR UPDATE
  USING (auth.uid() = user_1_id OR auth.uid() = user_2_id);

-- Messages Policies
CREATE POLICY "Users can read messages in their matches"
  ON public.messages FOR SELECT
  USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

CREATE POLICY "Users can send messages as themselves"
  ON public.messages FOR INSERT
  WITH CHECK (auth.uid() = sender_id);

-- Apartments Policies
CREATE POLICY "Public apartments are viewable by authenticated users"
  ON public.apartments FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Hosts can manage their own apartment listings"
  ON public.apartments FOR ALL
  USING (auth.uid() = host_user_id);

