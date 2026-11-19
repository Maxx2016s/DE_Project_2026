-- =========================================================
-- Instagram project: Phase 4 indexes
-- Run after creating the schema and loading the seed data.
-- =========================================================

BEGIN;

-- The project schema comes first; public is included so pg_trgm
-- works whether it is installed in instagram or public.
SET search_path TO instagram, public;

-- Needed for the substring and case-insensitive searches in R06 and R16.
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- R01, R02: find a user's active posts, newest first.
-- R01 still needs a global sort across followed accounts; its plan
-- will show whether these per-user lookups help.
CREATE INDEX IF NOT EXISTS idx_posts_active_user_created
    ON instagram.posts (user_id, created_at DESC)
    INCLUDE (post_id, post_type, like_count, comment_count)
    WHERE is_archived = FALSE;

-- R11, R19: find all posts for a user, including archived posts.
-- R19's rewritten query can use this to find each user's latest post.
CREATE INDEX IF NOT EXISTS idx_posts_user_created
    ON instagram.posts (user_id, created_at DESC);

-- R05, R12, R18, R20: support date-range filtering and joins on posts.
-- R18 must use a timestamp range in 06_optimized_queries.sql;
-- casting created_at to DATE prevents this index from serving that filter.
CREATE INDEX IF NOT EXISTS idx_posts_created
    ON instagram.posts (created_at)
    INCLUDE (post_id, user_id, post_type, like_count);

-- R17: focus date lookups on reels only.
-- R17 also needs its EXTRACT(YEAR ...) filter rewritten as a timestamp range.
CREATE INDEX IF NOT EXISTS idx_posts_reel_created
    ON instagram.posts (created_at)
    INCLUDE (post_id, user_id, like_count)
    WHERE post_type = 'REEL';

-- R05: find posts for a hashtag.
-- The existing post_hashtags primary key starts with post_id, not hashtag_id.
CREATE INDEX IF NOT EXISTS idx_post_hashtags_hashtag_post
    ON instagram.post_hashtags (hashtag_id, post_id);

-- R04, R13, R20: find comments belonging to a post.
CREATE INDEX IF NOT EXISTS idx_comments_post_created
    ON instagram.comments (post_id, created_at);

-- R04, R13: find replies to a comment.
-- R13's NOT IN query needs a NOT EXISTS rewrite; its NULL behavior differs.
CREATE INDEX IF NOT EXISTS idx_comments_parent
    ON instagram.comments (parent_comment_id)
    WHERE parent_comment_id IS NOT NULL;

-- R22: scan hidden comments newest first.
CREATE INDEX IF NOT EXISTS idx_comments_hidden_created
    ON instagram.comments (created_at DESC)
    WHERE is_hidden = TRUE;

-- R06: username prefix and full-name substring searches.
CREATE INDEX IF NOT EXISTS idx_users_username_trgm
    ON instagram.users USING GIN (username gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_users_full_name_trgm
    ON instagram.users USING GIN (full_name gin_trgm_ops);

-- R16: location substring search.
CREATE INDEX IF NOT EXISTS idx_posts_location_trgm
    ON instagram.posts USING GIN (location_name gin_trgm_ops);

-- R07, R19: find likes by post; date order also helps R07.
CREATE INDEX IF NOT EXISTS idx_likes_post_created
    ON instagram.likes (post_id, created_at DESC)
    INCLUDE (user_id);

-- R09, W06: find pending requests for an account, newest first.
CREATE INDEX IF NOT EXISTS idx_follows_pending_followee_created
    ON instagram.follows (followee_id, created_at DESC)
    INCLUDE (follower_id)
    WHERE status = 'PENDING';

-- R14, R15, R21, W04: find accepted followers by account.
CREATE INDEX IF NOT EXISTS idx_follows_accepted_followee
    ON instagram.follows (followee_id, follower_id)
    WHERE status = 'ACCEPTED';

-- R10: find stories for followed accounts.
-- R10 must use a timestamp range instead of DATE(created_at) to use
-- the created_at portion of this index as a range condition.
CREATE INDEX IF NOT EXISTS idx_stories_user_created
    ON instagram.stories (user_id, created_at DESC);

-- W05: find stories that have expired.
CREATE INDEX IF NOT EXISTS idx_stories_expires
    ON instagram.stories (expires_at);

-- Refresh planner statistics so the benchmark can choose among the indexes.
ANALYZE;

COMMIT;
