-- QuoteVault Quotes Database Setup
-- Run these commands in your Supabase SQL Editor

-- ============================================================================
-- 1. QUOTES TABLE
-- ============================================================================

-- Create quotes table
CREATE TABLE IF NOT EXISTS public.quotes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  text TEXT NOT NULL,
  author TEXT NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.quotes ENABLE ROW LEVEL SECURITY;

-- Create policy for public read access (all users can read quotes)
CREATE POLICY "Quotes are publicly readable"
  ON public.quotes
  FOR SELECT
  USING (true);

-- ============================================================================
-- 2. INDEXES FOR PERFORMANCE
-- ============================================================================

-- Index on category for fast filtering
CREATE INDEX IF NOT EXISTS quotes_category_idx ON public.quotes(category);

-- Index on author for fast filtering
CREATE INDEX IF NOT EXISTS quotes_author_idx ON public.quotes(author);

-- Index on created_at for ordering
CREATE INDEX IF NOT EXISTS quotes_created_at_idx ON public.quotes(created_at DESC);

-- Full-text search index on text
CREATE INDEX IF NOT EXISTS quotes_text_search_idx ON public.quotes USING gin(to_tsvector('english', text));

-- Full-text search index on author
CREATE INDEX IF NOT EXISTS quotes_author_search_idx ON public.quotes USING gin(to_tsvector('english', author));

-- ============================================================================
-- 3. SEED DATA - 100+ QUOTES
-- ============================================================================

-- Clear existing data (optional, comment out if you want to keep existing quotes)
-- TRUNCATE public.quotes;

-- Motivation Quotes (20)
INSERT INTO public.quotes (text, author, category) VALUES
('The only way to do great work is to love what you do.', 'Steve Jobs', 'Motivation'),
('Believe you can and you''re halfway there.', 'Theodore Roosevelt', 'Motivation'),
('It does not matter how slowly you go as long as you do not stop.', 'Confucius', 'Motivation'),
('Everything you''ve ever wanted is on the other side of fear.', 'George Addair', 'Motivation'),
('Success is not final, failure is not fatal: it is the courage to continue that counts.', 'Winston Churchill', 'Motivation'),
('Hardships often prepare ordinary people for an extraordinary destiny.', 'C.S. Lewis', 'Motivation'),
('Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine.', 'Roy T. Bennett', 'Motivation'),
('I learned that courage was not the absence of fear, but the triumph over it.', 'Nelson Mandela', 'Motivation'),
('There is only one thing that makes a dream impossible to achieve: the fear of failure.', 'Paulo Coelho', 'Motivation'),
('It''s not whether you get knocked down, it''s whether you get up.', 'Vince Lombardi', 'Motivation'),
('Your limitation—it''s only your imagination.', 'Unknown', 'Motivation'),
('Great things never come from comfort zones.', 'Unknown', 'Motivation'),
('Dream it. Wish it. Do it.', 'Unknown', 'Motivation'),
('Success doesn''t just find you. You have to go out and get it.', 'Unknown', 'Motivation'),
('The harder you work for something, the greater you''ll feel when you achieve it.', 'Unknown', 'Motivation'),
('Dream bigger. Do bigger.', 'Unknown', 'Motivation'),
('Don''t stop when you''re tired. Stop when you''re done.', 'Unknown', 'Motivation'),
('Wake up with determination. Go to bed with satisfaction.', 'Unknown', 'Motivation'),
('Do something today that your future self will thank you for.', 'Unknown', 'Motivation'),
('Little things make big days.', 'Unknown', 'Motivation');

-- Love Quotes (20)
INSERT INTO public.quotes (text, author, category) VALUES
('Love is composed of a single soul inhabiting two bodies.', 'Aristotle', 'Love'),
('The best thing to hold onto in life is each other.', 'Audrey Hepburn', 'Love'),
('Love is not only something you feel, it is something you do.', 'David Wilkerson', 'Love'),
('We are most alive when we''re in love.', 'John Updike', 'Love'),
('There is only one happiness in this life, to love and be loved.', 'George Sand', 'Love'),
('Love is friendship that has caught fire.', 'Ann Landers', 'Love'),
('Where there is love there is life.', 'Mahatma Gandhi', 'Love'),
('You know you''re in love when you can''t fall asleep because reality is finally better than your dreams.', 'Dr. Seuss', 'Love'),
('Love recognizes no barriers.', 'Maya Angelou', 'Love'),
('The best and most beautiful things in this world cannot be seen or even heard, but must be felt with the heart.', 'Helen Keller', 'Love'),
('Life without love is like a tree without blossoms or fruit.', 'Khalil Gibran', 'Love'),
('To love and be loved is to feel the sun from both sides.', 'David Viscott', 'Love'),
('Love is when the other person''s happiness is more important than your own.', 'H. Jackson Brown Jr.', 'Love'),
('In all the world, there is no heart for me like yours.', 'Maya Angelou', 'Love'),
('If I know what love is, it is because of you.', 'Herman Hesse', 'Love'),
('Love is the bridge between you and everything.', 'Rumi', 'Love'),
('The giving of love is an education in itself.', 'Eleanor Roosevelt', 'Love'),
('Love cures people - both the ones who give it and the ones who receive it.', 'Karl Menninger', 'Love'),
('Love does not dominate; it cultivates.', 'Johann Wolfgang von Goethe', 'Love'),
('The art of love is largely the art of persistence.', 'Albert Ellis', 'Love');

-- Success Quotes (20)
INSERT INTO public.quotes (text, author, category) VALUES
('Success is not the key to happiness. Happiness is the key to success.', 'Albert Schweitzer', 'Success'),
('Success usually comes to those who are too busy to be looking for it.', 'Henry David Thoreau', 'Success'),
('The way to get started is to quit talking and begin doing.', 'Walt Disney', 'Success'),
('Don''t be afraid to give up the good to go for the great.', 'John D. Rockefeller', 'Success'),
('I find that the harder I work, the more luck I seem to have.', 'Thomas Jefferson', 'Success'),
('Success is walking from failure to failure with no loss of enthusiasm.', 'Winston Churchill', 'Success'),
('The secret of success is to do the common thing uncommonly well.', 'John D. Rockefeller Jr.', 'Success'),
('Success is not how high you have climbed, but how you make a positive difference to the world.', 'Roy T. Bennett', 'Success'),
('Try not to become a man of success. Rather become a man of value.', 'Albert Einstein', 'Success'),
('Success is liking yourself, liking what you do, and liking how you do it.', 'Maya Angelou', 'Success'),
('The only place where success comes before work is in the dictionary.', 'Vidal Sassoon', 'Success'),
('Success is the sum of small efforts repeated day in and day out.', 'Robert Collier', 'Success'),
('Opportunities don''t happen. You create them.', 'Chris Grosser', 'Success'),
('Don''t let yesterday take up too much of today.', 'Will Rogers', 'Success'),
('You learn more from failure than from success. Don''t let it stop you.', 'Unknown', 'Success'),
('It''s not whether you get knocked down; it''s whether you get up.', 'Vince Lombardi', 'Success'),
('If you are working on something that you really care about, you don''t have to be pushed.', 'Steve Jobs', 'Success'),
('People who are crazy enough to think they can change the world, are the ones who do.', 'Rob Siltanen', 'Success'),
('Failure will never overtake me if my determination to succeed is strong enough.', 'Og Mandino', 'Success'),
('We may encounter many defeats but we must not be defeated.', 'Maya Angelou', 'Success');

-- Wisdom Quotes (20)
INSERT INTO public.quotes (text, author, category) VALUES
('The only true wisdom is in knowing you know nothing.', 'Socrates', 'Wisdom'),
('The fool doth think he is wise, but the wise man knows himself to be a fool.', 'William Shakespeare', 'Wisdom'),
('Turn your wounds into wisdom.', 'Oprah Winfrey', 'Wisdom'),
('The journey of a thousand miles begins with one step.', 'Lao Tzu', 'Wisdom'),
('By three methods we may learn wisdom: First, by reflection, which is noblest; Second, by imitation, which is easiest; and third by experience, which is the bitterest.', 'Confucius', 'Wisdom'),
('Knowledge speaks, but wisdom listens.', 'Jimi Hendrix', 'Wisdom'),
('The invariable mark of wisdom is to see the miraculous in the common.', 'Ralph Waldo Emerson', 'Wisdom'),
('We can easily forgive a child who is afraid of the dark; the real tragedy of life is when men are afraid of the light.', 'Plato', 'Wisdom'),
('It is the mark of an educated mind to be able to entertain a thought without accepting it.', 'Aristotle', 'Wisdom'),
('Wonder is the beginning of wisdom.', 'Socrates', 'Wisdom'),
('The unexamined life is not worth living.', 'Socrates', 'Wisdom'),
('Knowing yourself is the beginning of all wisdom.', 'Aristotle', 'Wisdom'),
('The only way to deal with an unfree world is to become so absolutely free that your very existence is an act of rebellion.', 'Albert Camus', 'Wisdom'),
('In the middle of difficulty lies opportunity.', 'Albert Einstein', 'Wisdom'),
('The greatest glory in living lies not in never falling, but in rising every time we fall.', 'Nelson Mandela', 'Wisdom'),
('Life is what happens when you''re busy making other plans.', 'John Lennon', 'Wisdom'),
('Change your thoughts and you change your world.', 'Norman Vincent Peale', 'Wisdom'),
('The mind is everything. What you think you become.', 'Buddha', 'Wisdom'),
('Yesterday is history, tomorrow is a mystery, today is a gift of God, which is why we call it the present.', 'Bill Keane', 'Wisdom'),
('Do not dwell in the past, do not dream of the future, concentrate the mind on the present moment.', 'Buddha', 'Wisdom');

-- Humor Quotes (20)
INSERT INTO public.quotes (text, author, category) VALUES
('I''m not superstitious, but I am a little stitious.', 'Michael Scott', 'Humor'),
('I never forget a face, but in your case, I''ll be glad to make an exception.', 'Groucho Marx', 'Humor'),
('Behind every great man is a woman rolling her eyes.', 'Jim Carrey', 'Humor'),
('I used to think I was indecisive, but now I''m not so sure.', 'Unknown', 'Humor'),
('The difference between stupidity and genius is that genius has its limits.', 'Albert Einstein', 'Humor'),
('All you need is love. But a little chocolate now and then doesn''t hurt.', 'Charles M. Schulz', 'Humor'),
('I''m writing a book. I''ve got the page numbers done.', 'Steven Wright', 'Humor'),
('If you think you are too small to make a difference, try sleeping with a mosquito.', 'Dalai Lama', 'Humor'),
('Age is an issue of mind over matter. If you don''t mind, it doesn''t matter.', 'Mark Twain', 'Humor'),
('A day without sunshine is like, you know, night.', 'Steve Martin', 'Humor'),
('The road to success is dotted with many tempting parking spaces.', 'Will Rogers', 'Humor'),
('I intend to live forever. So far, so good.', 'Steven Wright', 'Humor'),
('People say nothing is impossible, but I do nothing every day.', 'A.A. Milne', 'Humor'),
('Better to remain silent and be thought a fool than to speak out and remove all doubt.', 'Abraham Lincoln', 'Humor'),
('If I were two-faced, would I be wearing this one?', 'Abraham Lincoln', 'Humor'),
('The only mystery in life is why the kamikaze pilots wore helmets.', 'Al McGuire', 'Humor'),
('Light travels faster than sound. This is why some people appear bright until you hear them speak.', 'Alan Dundes', 'Humor'),
('Nobody realizes that some people expend tremendous energy merely to be normal.', 'Albert Camus', 'Humor'),
('Men marry women hoping they will never change. Women marry men hoping they will change. Invariably they are both disappointed.', 'Albert Einstein', 'Humor'),
('The best time to plant a tree was 20 years ago. The second best time is now. Unless you''re a time traveler.', 'Unknown', 'Humor');

-- ============================================================================
-- 4. VERIFY SETUP
-- ============================================================================

-- Check total count
SELECT COUNT(*) as total_quotes FROM public.quotes;

-- Check distribution by category
SELECT category, COUNT(*) as quote_count
FROM public.quotes
GROUP BY category
ORDER BY category;

-- Sample query with pagination
SELECT id, text, author, category, created_at
FROM public.quotes
ORDER BY created_at DESC
LIMIT 20;

-- ============================================================================
-- SETUP COMPLETE
-- ============================================================================
-- You now have 100 quotes across 5 categories!
-- Ready for the QuoteVault app to fetch and display them.

