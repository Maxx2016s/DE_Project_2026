
-- =========================================================
-- 08_partitioning.sql
-- HASH partitioning of likes table on post_id
-- =========================================================

-- Create a partitioned version of the likes table.
CREATE TABLE instagram.likes_partitioned (
    user_id INTEGER NOT NULL,
    post_id INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,

    PRIMARY KEY (user_id, post_id),

    CONSTRAINT fk_likes_partitioned_user
        FOREIGN KEY (user_id)
        REFERENCES instagram.users(user_id),

    CONSTRAINT fk_likes_partitioned_post
        FOREIGN KEY (post_id)
        REFERENCES instagram.posts(post_id)
)
PARTITION BY HASH (post_id);


-- Create 8 hash partitions.
CREATE TABLE instagram.likes_p0
    PARTITION OF instagram.likes_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 0);

CREATE TABLE instagram.likes_p1
    PARTITION OF instagram.likes_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 1);

CREATE TABLE instagram.likes_p2
    PARTITION OF instagram.likes_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 2);

CREATE TABLE instagram.likes_p3
    PARTITION OF instagram.likes_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 3);

CREATE TABLE instagram.likes_p4
    PARTITION OF instagram.likes_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 4);

CREATE TABLE instagram.likes_p5
    PARTITION OF instagram.likes_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 5);

CREATE TABLE instagram.likes_p6
    PARTITION OF instagram.likes_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 6);

CREATE TABLE instagram.likes_p7
    PARTITION OF instagram.likes_partitioned
    FOR VALUES WITH (MODULUS 8, REMAINDER 7);
