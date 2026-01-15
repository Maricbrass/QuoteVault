-- QuoteVault Favorites, Likes, and Collections Setup
-- Run these commands in your Supabase SQL Editor after quotes_setup.sql

-- ============================================================================
-- 1. USER_FAVORITES TABLE
-- ============================================================================

-- Create user_favorites table
CREATE TABLE IF NOT EXISTS public.user_favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  quote_id UUID NOT NULL REFERENCES public.quotes(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, quote_id)
);

-- Enable Row Level Security
ALTER TABLE public.user_favorites ENABLE ROW LEVEL SECURITY;

-- Users can view their own favorites
CREATE POLICY "Users can view own favorites"
  ON public.user_favorites
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own favorites
CREATE POLICY "Users can insert own favorites"
  ON public.user_favorites
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own favorites
CREATE POLICY "Users can delete own favorites"
  ON public.user_favorites
  FOR DELETE
  USING (auth.uid() = user_id);

-- Create index on user_id for fast lookups
CREATE INDEX IF NOT EXISTS user_favorites_user_id_idx ON public.user_favorites(user_id);

-- Create index on quote_id for reverse lookups
CREATE INDEX IF NOT EXISTS user_favorites_quote_id_idx ON public.user_favorites(quote_id);

-- ============================================================================
-- 2. QUOTE_LIKES TABLE
-- ============================================================================

-- Create quote_likes table
CREATE TABLE IF NOT EXISTS public.quote_likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  quote_id UUID NOT NULL REFERENCES public.quotes(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, quote_id)
);

-- Enable Row Level Security
ALTER TABLE public.quote_likes ENABLE ROW LEVEL SECURITY;

-- Anyone can view likes (for like counts)
CREATE POLICY "Anyone can view likes"
  ON public.quote_likes
  FOR SELECT
  USING (true);

-- Users can insert their own likes
CREATE POLICY "Users can insert own likes"
  ON public.quote_likes
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own likes
CREATE POLICY "Users can delete own likes"
  ON public.quote_likes
  FOR DELETE
  USING (auth.uid() = user_id);

-- Create index on quote_id for like count aggregation
CREATE INDEX IF NOT EXISTS quote_likes_quote_id_idx ON public.quote_likes(quote_id);

-- Create index on user_id for user's like history
CREATE INDEX IF NOT EXISTS quote_likes_user_id_idx ON public.quote_likes(user_id);

-- ============================================================================
-- 3. COLLECTIONS TABLE
-- ============================================================================

-- Create collections table
CREATE TABLE IF NOT EXISTS public.collections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  is_collaborative BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.collections ENABLE ROW LEVEL SECURITY;

-- Users can view their own collections
CREATE POLICY "Users can view own collections"
  ON public.collections
  FOR SELECT
  USING (auth.uid() = owner_id);

-- Users can insert their own collections
CREATE POLICY "Users can insert own collections"
  ON public.collections
  FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

-- Users can update their own collections
CREATE POLICY "Users can update own collections"
  ON public.collections
  FOR UPDATE
  USING (auth.uid() = owner_id);

-- Users can delete their own collections
CREATE POLICY "Users can delete own collections"
  ON public.collections
  FOR DELETE
  USING (auth.uid() = owner_id);

-- Create index on owner_id for fast lookups
CREATE INDEX IF NOT EXISTS collections_owner_id_idx ON public.collections(owner_id);

-- ============================================================================
-- 4. COLLECTION_QUOTES TABLE
-- ============================================================================

-- Create collection_quotes junction table
CREATE TABLE IF NOT EXISTS public.collection_quotes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  collection_id UUID NOT NULL REFERENCES public.collections(id) ON DELETE CASCADE,
  quote_id UUID NOT NULL REFERENCES public.quotes(id) ON DELETE CASCADE,
  added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(collection_id, quote_id)
);

-- Enable Row Level Security
ALTER TABLE public.collection_quotes ENABLE ROW LEVEL SECURITY;

-- Users can view quotes in their own collections
CREATE POLICY "Users can view own collection quotes"
  ON public.collection_quotes
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.collections
      WHERE collections.id = collection_quotes.collection_id
      AND collections.owner_id = auth.uid()
    )
  );

-- Users can add quotes to their own collections
CREATE POLICY "Users can insert into own collections"
  ON public.collection_quotes
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.collections
      WHERE collections.id = collection_quotes.collection_id
      AND collections.owner_id = auth.uid()
    )
  );

-- Users can remove quotes from their own collections
CREATE POLICY "Users can delete from own collections"
  ON public.collection_quotes
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.collections
      WHERE collections.id = collection_quotes.collection_id
      AND collections.owner_id = auth.uid()
    )
  );

-- Create index on collection_id for fast lookups
CREATE INDEX IF NOT EXISTS collection_quotes_collection_id_idx ON public.collection_quotes(collection_id);

-- Create index on quote_id for reverse lookups
CREATE INDEX IF NOT EXISTS collection_quotes_quote_id_idx ON public.collection_quotes(quote_id);

-- ============================================================================
-- 5. FUNCTIONS FOR LIKE COUNTS
-- ============================================================================

-- Function to get like count for a quote
CREATE OR REPLACE FUNCTION get_quote_like_count(quote_uuid UUID)
RETURNS INTEGER AS $$
BEGIN
  RETURN (
    SELECT COUNT(*)::INTEGER
    FROM public.quote_likes
    WHERE quote_id = quote_uuid
  );
END;
$$ LANGUAGE plpgsql STABLE;

-- Function to check if user liked a quote
CREATE OR REPLACE FUNCTION user_liked_quote(quote_uuid UUID, user_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.quote_likes
    WHERE quote_id = quote_uuid AND user_id = user_uuid
  );
END;
$$ LANGUAGE plpgsql STABLE;

-- ============================================================================
-- 6. TRIGGER TO UPDATE COLLECTION UPDATED_AT
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_collection_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at
DROP TRIGGER IF EXISTS on_collection_updated ON public.collections;
CREATE TRIGGER on_collection_updated
  BEFORE UPDATE ON public.collections
  FOR EACH ROW
  EXECUTE FUNCTION update_collection_timestamp();

-- ============================================================================
-- 7. VERIFY SETUP
-- ============================================================================

-- Check if tables exist
SELECT
  EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'user_favorites') AS user_favorites_exists,
  EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'quote_likes') AS quote_likes_exists,
  EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'collections') AS collections_exists,
  EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'collection_quotes') AS collection_quotes_exists;

-- Check if policies are enabled
SELECT tablename, policyname
FROM pg_policies
WHERE schemaname = 'public'
AND tablename IN ('user_favorites', 'quote_likes', 'collections', 'collection_quotes');

-- ============================================================================
-- SETUP COMPLETE
-- ============================================================================
-- Your QuoteVault app now has favorites, likes, and collections!
-- Ready for user interactions and engagement features.

