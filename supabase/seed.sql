-- ==============================================================================
-- ROOMSYNC SUPABASE DATABASE SEED DATA
-- Run this in the Supabase SQL Editor after running schema.sql
-- ==============================================================================

-- Clean up any existing sample data
DELETE FROM public.messages WHERE match_id IN (
  SELECT id FROM public.matches WHERE user_1_id IN ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002')
);
DELETE FROM public.matches WHERE user_1_id IN ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002');
DELETE FROM public.profiles WHERE user_id LIKE '00000000-0000-0000-0000-%';

-- 1. Insert 10 diverse NYC flatmate candidates
INSERT INTO public.profiles (
  user_id, name, age, gender, occupation, bio, avatar_url, image_urls,
  budget, location, preferred_locations, sleep_start, sleep_end,
  cleanliness_score, smoking, pets, is_verified, habits
) VALUES
(
  '00000000-0000-0000-0000-000000000001',
  'Elena Rostova',
  24,
  'Female',
  'UX/UI Designer',
  'Loves pour-over coffee, curated Spotify playlists, and quiet weeknights. Very respectful of shared spaces and cleanliness.',
  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=80',
  ARRAY['https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=80', 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80'],
  1600.0,
  'Brooklyn, NY',
  ARRAY['Williamsburg', 'Greenpoint', 'Bushwick'],
  '23:00',
  '07:00',
  4,
  'nonSmoker',
  'petFriendly',
  TRUE,
  '{"cleanlinessRating": 4, "bedtime": "11:00 PM", "wakeTime": "07:00 AM", "sleepSchedule": "flexible", "smoking": "nonSmoker", "petPreference": "petFriendly", "budgetMin": 1200.0, "budgetMax": 1600.0, "dietaryPreference": "Vegetarian", "workSchedule": "Hybrid (3 days WFH)"}'::jsonb
),
(
  '00000000-0000-0000-0000-000000000002',
  'Marcus Vance',
  28,
  'Male',
  'Software Engineer',
  'Night owl coder who loves hosting casual game nights. Upfront about dishes, loves cooking spicy meals, and respects quiet hours.',
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=800&q=80',
  ARRAY['https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=800&q=80'],
  1800.0,
  'Manhattan, NY',
  ARRAY['East Village', 'Lower East Side', 'Williamsburg'],
  '01:00',
  '09:00',
  3,
  'outsideOnly',
  'hasCat',
  TRUE,
  '{"cleanlinessRating": 3, "bedtime": "01:00 AM", "wakeTime": "09:00 AM", "sleepSchedule": "nightOwl", "smoking": "outsideOnly", "petPreference": "hasCat", "budgetMin": 1300.0, "budgetMax": 1800.0, "dietaryPreference": "Omnivore", "workSchedule": "Fully Remote"}'::jsonb
),
(
  '00000000-0000-0000-0000-000000000003',
  'Priya Patel',
  26,
  'Female',
  'Data Analyst',
  'Early bird yogi and runner. Morning person who values peace before 9 AM and keeps the common areas neat.',
  'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=800&q=80',
  ARRAY['https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=800&q=80'],
  1750.0,
  'Queens, NY',
  ARRAY['Astoria', 'Long Island City', 'Greenpoint'],
  '22:00',
  '06:00',
  5,
  'nonSmoker',
  'petFriendly',
  TRUE,
  '{"cleanlinessRating": 5, "bedtime": "10:00 PM", "wakeTime": "06:00 AM", "sleepSchedule": "earlyBird", "smoking": "nonSmoker", "petPreference": "petFriendly", "budgetMin": 1250.0, "budgetMax": 1750.0, "dietaryPreference": "Vegetarian", "workSchedule": "In-Office (4 days)"}'::jsonb
),
(
  '00000000-0000-0000-0000-000000000004',
  'Liam Gallagher',
  27,
  'Male',
  'Photographer & Editor',
  'Travel frequently for documentary projects. When home, I enjoy vinyl records and brewing sourdough.',
  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&q=80',
  ARRAY['https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&q=80'],
  1500.0,
  'Brooklyn, NY',
  ARRAY['Greenpoint', 'Williamsburg', 'Crown Heights'],
  '00:00',
  '08:00',
  4,
  'nonSmoker',
  'hasDog',
  FALSE,
  '{"cleanlinessRating": 4, "bedtime": "12:00 AM", "wakeTime": "08:00 AM", "sleepSchedule": "flexible", "smoking": "nonSmoker", "petPreference": "hasDog", "budgetMin": 1000.0, "budgetMax": 1500.0, "dietaryPreference": "Omnivore", "workSchedule": "Freelance / Travel"}'::jsonb
),
(
  '00000000-0000-0000-0000-000000000005',
  'Sofia Morales',
  23,
  'Female',
  'Graduate Student & TA',
  'Masters student in literature. Spends most days studying at the library. Very quiet, clean, and considerate.',
  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
  ARRAY['https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80'],
  1250.0,
  'Brooklyn, NY',
  ARRAY['Bushwick', 'Bed-Stuy', 'Crown Heights'],
  '23:30',
  '07:30',
  4,
  'nonSmoker',
  'allergic',
  TRUE,
  '{"cleanlinessRating": 4, "bedtime": "11:30 PM", "wakeTime": "07:30 AM", "sleepSchedule": "flexible", "smoking": "nonSmoker", "petPreference": "allergic", "budgetMin": 900.0, "budgetMax": 1250.0, "dietaryPreference": "Vegan", "workSchedule": "Student / On-Campus"}'::jsonb
);

-- 2. Insert 5 NYC Apartments hosted by our flatmates
DELETE FROM public.apartments WHERE host_user_id IN ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000005');

INSERT INTO public.apartments (
  host_user_id, title, neighborhood, city, monthly_rent, bedrooms, bathrooms,
  is_furnished, bills_included, available_from, amenities, image_urls, description
) VALUES
(
  '00000000-0000-0000-0000-000000000001',
  'Sun-drenched Loft with High Ceilings & Skylights',
  'Williamsburg',
  'Brooklyn, NY',
  1450.0,
  2,
  1,
  TRUE,
  FALSE,
  NOW() + INTERVAL '15 days',
  ARRAY['In-unit Washer/Dryer', 'Rooftop Access', 'Dishwasher', 'Natural Light', 'Central AC'],
  ARRAY['https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=1000&q=80', 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=1000&q=80'],
  'Massive open-concept living area with 14ft wood-beamed ceilings and polished concrete floors. Private bedroom with large closet. 4 minute walk to the Bedford L train.'
),
(
  '00000000-0000-0000-0000-000000000004',
  'Historic Brownstone with Private Backyard & Patio',
  'Greenpoint',
  'Brooklyn, NY',
  1550.0,
  3,
  2,
  FALSE,
  TRUE,
  NOW() + INTERVAL '20 days',
  ARRAY['Private Garden', 'Pet Friendly', 'Exposed Brick', 'Eat-in Kitchen', 'Hardwood Floors'],
  ARRAY['https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1000&q=80'],
  'Charming tree-lined street right next to Transmitter Park. Huge private backyard perfect for dogs and weekend barbecues. High-speed fiber internet and heat/hot water included.'
),
(
  '00000000-0000-0000-0000-000000000002',
  'Luxury 42nd-Floor Corner 2BR with Harbor Views',
  'Financial District',
  'Manhattan, NY',
  2200.0,
  2,
  2,
  TRUE,
  FALSE,
  NOW() + INTERVAL '10 days',
  ARRAY['24/7 Doorman', 'Fitness Center', 'Indoor Pool', 'Elevator', 'Lounge'],
  ARRAY['https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=1000&q=80'],
  'Floor-to-ceiling windows overlooking the Hudson River. En-suite marble bathroom, full chef kitchen with Sub-Zero appliances, and state-of-the-art building amenities.'
),
(
  '00000000-0000-0000-0000-000000000005',
  'Classic Pre-War 2BR near Brooklyn Bridge Park',
  'Cobble Hill',
  'Brooklyn, NY',
  1650.0,
  2,
  1,
  FALSE,
  FALSE,
  NOW() + INTERVAL '30 days',
  ARRAY['Balcony', 'Dishwasher', 'Laundry in Building', 'Quiet Street'],
  ARRAY['https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=1000&q=80'],
  'Located in the heart of Cobble Hill on a picturesque cobblestone lane. Walking distance to great wine bars, artisan bakeries, and multiple subway lines (F/G/R/2/3).'
);

-- Note: When a real user signs up, they will swipe on these seeded profiles and apartments immediately!


