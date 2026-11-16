# Instagram Social Media Database — Schema Design

## 1. Introduction

This document describes the relational database schema designed for the Instagram Social Media Database project.

The database is implemented using PostgreSQL 18 and models the core functionality of a social media platform, including users, posts, followers, hashtags, media, likes, comments and stories.

The database is organized into a PostgreSQL schema named `instagram`, containing nine relational tables.

### Project Overview

| Attribute | Details |
|---|---|
| Database | instagram_db |
| DBMS | PostgreSQL 18 |
| Schema | instagram |
| Number of tables | 9 |
| Dataset records | 1,198,446 |
| Data format | CSV |
| Design approach | Relational database model |

## 2. Database Schema Overview

The database contains the following nine tables:

| Table | Purpose |
|---|---|
| users | Stores user profile and account information |
| follows | Stores relationships between followers and followed users |
| hashtags | Stores unique hashtags |
| posts | Stores posts created by users |
| post_hashtags | Connects posts with hashtags |
| post_media | Stores media associated with posts |
| likes | Stores user likes on posts |
| comments | Stores comments and replies on posts |
| stories | Stores temporary user stories |

### 2.1 Users

The `users` table stores information about registered users.

**Primary Key:** `user_id`

**Important constraints:**
- `username` is NOT NULL and UNIQUE.
- `email` is UNIQUE.
- `account_type` must be BUSINESS, CREATOR or PERSONAL.
- `followers_count` and `following_count` must be non-negative.
- Profile and account attributes such as `is_private` and `is_verified` are mandatory.

### 2.2 Follows

The `follows` table represents relationships between users.

**Composite Primary Key:** `(follower_id, followee_id)`

**Foreign Keys:**
- `follower_id` references `users(user_id)`.
- `followee_id` references `users(user_id)`.

**Important constraints:**
- A user cannot follow themselves.
- Follow status must be ACCEPTED or PENDING.
- The same follower-followee pair cannot occur more than once because of the composite primary key.

### 2.3 Hashtags

The `hashtags` table stores unique hashtags used in posts.

**Primary Key:** `hashtag_id`

**Important constraints:**
- `tag` is NOT NULL.
- `tag` must be UNIQUE.

### 2.4 Posts

The `posts` table stores content created by users.

**Primary Key:** `post_id`

**Foreign Key:**
- `user_id` references `users(user_id)`.

**Important constraints:**
- `post_type` must be CAROUSEL, PHOTO, REEL or VIDEO.
- `like_count` must be non-negative.
- `comment_count` must be non-negative.
- `is_archived` defaults to FALSE.

### 2.5 Post Hashtags

The `post_hashtags` table implements the many-to-many relationship between posts and hashtags.

**Composite Primary Key:** `(post_id, hashtag_id)`

**Foreign Keys:**
- `post_id` references `posts(post_id)`.
- `hashtag_id` references `hashtags(hashtag_id)`.

A post can have multiple hashtags, and a hashtag can be associated with multiple posts.

### 2.6 Post Media

The `post_media` table stores media files associated with posts.

**Composite Primary Key:** `(post_id, position)`

**Foreign Key:**
- `post_id` references `posts(post_id)`.

**Important constraints:**
- `media_type` must be IMAGE or VIDEO.
- `position` must be greater than zero.
- Width and height must be positive when provided.
- Duration must be non-negative when provided.

The composite primary key ensures that a post cannot have two media records at the same position.

### 2.7 Likes

The `likes` table stores which users have liked which posts.

**Composite Primary Key:** `(user_id, post_id)`

**Foreign Keys:**
- `user_id` references `users(user_id)`.
- `post_id` references `posts(post_id)`.

The composite primary key prevents the same user from liking the same post more than once.

### 2.8 Comments

The `comments` table stores comments and replies on posts.

**Primary Key:** `comment_id`

**Foreign Keys:**
- `post_id` references `posts(post_id)`.
- `user_id` references `users(user_id)`.
- `parent_comment_id` references `comments(comment_id)`.

The self-referencing foreign key allows a comment to be a reply to another comment.

A CHECK constraint prevents a comment from being its own parent.

### 2.9 Stories

The `stories` table stores temporary content uploaded by users.

**Primary Key:** `story_id`

**Foreign Key:**
- `user_id` references `users(user_id)`.

**Important constraints:**
- `media_type` must be IMAGE or VIDEO.
- `view_count` must be non-negative.
- `expires_at` must be later than `created_at`.

The schema checks that a story expires after it is created. It does not enforce an exact 24-hour duration.

---

## 3. Entity Relationships

The database contains the following relationships:

| Relationship | Cardinality | Description |
|---|---|---|
| Users → Posts | One-to-Many | One user can create multiple posts |
| Users → Stories | One-to-Many | One user can create multiple stories |
| Users → Follows | One-to-Many | A user can follow multiple users and be followed by multiple users |
| Users → Likes | One-to-Many | A user can like multiple posts |
| Users → Comments | One-to-Many | A user can write multiple comments |
| Posts → Post Media | One-to-Many | A post can contain multiple media records |
| Posts → Likes | One-to-Many | A post can receive multiple likes |
| Posts → Comments | One-to-Many | A post can receive multiple comments |
| Posts → Post Hashtags | One-to-Many | A post can be associated with multiple hashtags |
| Hashtags → Post Hashtags | One-to-Many | A hashtag can be used in multiple posts |
| Comments → Comments | One-to-Many | A comment can have multiple replies |
| Users → Users through Follows | Many-to-Many | Users can follow one another |
| Posts ↔️ Hashtags | Many-to-Many | Posts can contain multiple hashtags and hashtags can belong to multiple posts |

The many-to-many relationships are implemented using junction tables:

- `follows`
- `post_hashtags`
- `likes`

The `comments` table also contains a self-referencing relationship to support threaded replies.

---

## 4. Primary Keys and Foreign Keys

### 4.1 Primary Keys

| Table | Primary Key |
|---|---|
| users | user_id |
| follows | follower_id, followee_id |
| hashtags | hashtag_id |
| posts | post_id |
| post_hashtags | post_id, hashtag_id |
| post_media | post_id, position |
| likes | user_id, post_id |
| comments | comment_id |
| stories | story_id |

### 4.2 Foreign Keys

| Table | Foreign Key | Referenced Table |
|---|---|---|
| follows | follower_id | users(user_id) |
| follows | followee_id | users(user_id) |
| posts | user_id | users(user_id) |
| post_hashtags | post_id | posts(post_id) |
| post_hashtags | hashtag_id | hashtags(hashtag_id) |
| post_media | post_id | posts(post_id) |
| likes | user_id | users(user_id) |
| likes | post_id | posts(post_id) |
| comments | post_id | posts(post_id) |
| comments | user_id | users(user_id) |
| comments | parent_comment_id | comments(comment_id) |
| stories | user_id | users(user_id) |

Foreign keys maintain referential integrity by ensuring that referenced records exist.

No explicit `ON DELETE CASCADE` action is defined in the supplied SQL. PostgreSQL's default foreign-key delete behaviour therefore applies.

---

## 5. Integrity Constraints

The database uses PRIMARY KEY, FOREIGN KEY, UNIQUE, NOT NULL and CHECK constraints to maintain data integrity.

### 5.1 CHECK Constraints

The schema implements 17 named CHECK constraints.

| Constraint | Table | Purpose |
|---|---|---|
| chk_users_account_type | users | Restricts account types to BUSINESS, CREATOR and PERSONAL |
| chk_users_followers | users | Ensures followers_count is non-negative |
| chk_users_following | users | Ensures following_count is non-negative |
| chk_follows_status | follows | Restricts status to ACCEPTED or PENDING |
| chk_follows_not_self | follows | Prevents users from following themselves |
| chk_posts_type | posts | Restricts post types to CAROUSEL, PHOTO, REEL and VIDEO |
| chk_posts_like_count | posts | Ensures like_count is non-negative |
| chk_posts_comment_count | posts | Ensures comment_count is non-negative |
| chk_post_media_type | post_media | Restricts media types to IMAGE and VIDEO |
| chk_post_media_position | post_media | Ensures media position is positive |
| chk_post_media_width | post_media | Ensures width is positive when provided |
| chk_post_media_height | post_media | Ensures height is positive when provided |
| chk_post_media_duration | post_media | Ensures duration is non-negative when provided |
| chk_comments_not_self_parent | comments | Prevents a comment from being its own parent |
| chk_stories_media_type | stories | Restricts story media types to IMAGE and VIDEO |
| chk_stories_view_count | stories | Ensures view_count is non-negative |
| chk_stories_expiry | stories | Ensures expires_at is later than created_at |

### 5.2 UNIQUE Constraints

| Table | Column | Purpose |
|---|---|---|
| users | username | Prevents duplicate usernames |
| users | email | Prevents duplicate non-NULL email values |
| hashtags | tag | Prevents duplicate hashtags |

### 5.3 NOT NULL Constraints

Mandatory attributes such as primary identifiers, foreign-key columns, timestamps, account types, post types and other required values are defined using NOT NULL.

### 5.4 Composite Primary Keys

The following composite keys prevent duplicate relationship records:

- `follows(follower_id, followee_id)`
- `post_hashtags(post_id, hashtag_id)`
- `post_media(post_id, position)`
- `likes(user_id, post_id)`

These constraints are particularly important for preventing duplicate associations.

---

## 6. Functional Dependencies

Functional dependencies describe how one attribute or a set of attributes determines other attributes in a relation.

Based on the declared primary keys, the following dependencies hold.

| Table | Functional Dependency |
|---|---|
| users | user_id → all other user attributes |
| follows | (follower_id, followee_id) → status, created_at |
| hashtags | hashtag_id → tag |
| posts | post_id → all other post attributes |
| post_hashtags | (post_id, hashtag_id) → no additional non-key attributes |
| post_media | (post_id, position) → media_type, media_url, width, height, duration_sec |
| likes | (user_id, post_id) → created_at |
| comments | comment_id → all other comment attributes |
| stories | story_id → all other story attributes |

The declared UNIQUE constraints also imply:

- `users.username → user_id` and other user attributes.
- `hashtags.tag → hashtag_id`.

The email column is UNIQUE but nullable, so it does not identify every user.

These dependencies are based on the declared keys and uniqueness rules. Additional business-level functional dependencies would require separate validation.

---

## 7. Normalization Analysis

Normalization organizes data to reduce redundancy and prevent insertion, update and deletion anomalies.

### 7.1 First Normal Form (1NF)

A relation is in 1NF when:
- Each column contains atomic values.
- There are no repeating groups.
- Each record can be uniquely identified.

The Instagram database satisfies 1NF because:
- Each attribute stores a single value.
- Repeating relationships are represented using separate tables.
- Primary keys uniquely identify records.
- Multiple post hashtags are stored in `post_hashtags`.
- Multiple media records are stored in `post_media`.

Therefore, all nine tables satisfy the intended 1NF design.

### 7.2 Second Normal Form (2NF)

A relation is in 2NF when:
- It is already in 1NF.
- Every non-prime attribute is fully functionally dependent on the entire candidate key.
- There are no partial dependencies on a subset of a composite candidate key.

Tables with single-column primary keys do not have partial dependencies on a subset of their primary keys.

For tables with composite primary keys:

- `follows`: status and created_at depend on both follower_id and followee_id.
- `post_hashtags`: the combination of post_id and hashtag_id identifies the association.
- `post_media`: media attributes depend on both post_id and position.
- `likes`: created_at depends on both user_id and post_id.

No partial dependencies are intended in these relations.

Therefore, the schema is designed to satisfy 2NF.

### 7.3 Third Normal Form (3NF)

A relation is in 3NF when:
- It is already in 2NF.
- Non-key attributes do not have inappropriate transitive dependencies on candidate keys.

The schema separates users, posts, hashtags, media, likes, comments and stories into different relations.

For example:
- User profile details are stored in `users`, not repeated in `posts`.
- Hashtag details are stored in `hashtags`, not duplicated in every post.
- Media information is stored separately in `post_media`.
- Like relationships are stored in `likes`.

This reduces duplication and update anomalies.

The declared key-based dependencies do not indicate transitive dependencies among non-key attributes. Additional business-level dependencies should be reviewed before claiming a complete formal proof of 3NF.

### 7.4 Boyce-Codd Normal Form (BCNF)

BCNF requires every determinant in a non-trivial functional dependency to be a superkey.

The declared primary-key and unique-key dependencies satisfy this requirement in the intended design.

However, a complete BCNF proof would require identifying and checking all business-level functional dependencies, not just those declared by the SQL schema.

---

## 8. Derived and Redundant Attributes

Some attributes store values that can be calculated from other records or timestamps.

| Attribute | Derived From | Reason for Storage |
|---|---|---|
| users.followers_count | Number of users following a user | Faster profile statistics |
| users.following_count | Number of users followed by a user | Faster profile statistics |
| posts.like_count | Number of likes associated with a post | Faster display of post engagement |
| posts.comment_count | Number of comments associated with a post | Faster display of comment totals |
| stories.expires_at | Creation timestamp and expiry policy | Directly stores the expiration time |

These attributes are useful for reducing repeated aggregation calculations.

However, they introduce consistency risks.

For example:
- A like may be inserted without updating `like_count`.
- A comment may be deleted without updating `comment_count`.
- A follow relationship may change without updating follower or following counts.

The current schema enforces non-negative values for these counters, but it does not automatically synchronize them with their related records through triggers.

Consistency must therefore be maintained by application logic, transactions or other validation mechanisms.

The current schema also checks that a story expires after it is created, but does not enforce a fixed 24-hour lifetime.

---

## 9. Data Loading and Validation

The dataset was loaded from CSV files using PostgreSQL's `\copy` command.

The loading order respected foreign-key dependencies:

1. users
2. hashtags
3. follows
4. posts
5. stories
6. post_hashtags
7. post_media
8. likes
9. comments

The `ANALYZE` command was executed after loading to update PostgreSQL table statistics.

### 9.1 Loaded Row Counts

The following counts were obtained from the actual CSV loading output and independently verified using SQL COUNT queries.

| Table | Expected / Actual Rows |
|---|---:|
| users | 30,000 |
| follows | 258,588 |
| hashtags | 50 |
| posts | 60,000 |
| post_hashtags | 150,000 |
| post_media | 89,854 |
| likes | 419,954 |
| comments | 150,000 |
| stories | 40,000 |
| **Total** | **1,198,446** |

All nine tables contain the expected number of records.

### 9.2 Integrity Checks

Three integrity checks were executed against the loaded database.

#### Check 1: Replies Must Belong to the Same Post as Their Parent Comment

```sql
SELECT COUNT(*) AS invalid_replies
FROM instagram.comments c
JOIN instagram.comments parent
ON c.parent_comment_id = parent.comment_id
WHERE c.post_id <> parent.post_id;
```

**Actual result: 0**

No replies were found whose parent comment belonged to a different post.

#### Check 2: Stored Like Counts Must Match Actual Likes

```sql
SELECT COUNT(*) AS mismatched_like_counts
FROM instagram.posts p
LEFT JOIN (
    SELECT post_id, COUNT(*) AS actual_likes
    FROM instagram.likes
    GROUP BY post_id
) l ON p.post_id = l.post_id
WHERE p.like_count <> COALESCE(l.actual_likes, 0);
```

**Actual result: 0**

All stored post like counts match the actual number of records in the likes table.

#### Check 3: Stored Comment Counts Must Match Actual Comments

```sql
SELECT COUNT(*) AS mismatched_comment_counts
FROM instagram.posts p
LEFT JOIN (
    SELECT post_id, COUNT(*) AS actual_comments
    FROM instagram.comments
    GROUP BY post_id
) c ON p.post_id = c.post_id
WHERE p.comment_count <> COALESCE(c.actual_comments, 0);
```

**Actual result: 0**

All stored post comment counts match the actual number of records in the comments table.

### 9.3 Validation Summary

| Validation | Actual Result | Status |
|---|---:|---|
| Total records loaded | 1,198,446 | Passed |
| Expected table row counts | All matched | Passed |
| Invalid replies | 0 | Passed |
| Mismatched like counts | 0 | Passed |
| Mismatched comment counts | 0 | Passed |

These results confirm that the tested data relationships and stored engagement counts are consistent in the loaded dataset.

---

## 10. Conclusion

The Instagram Social Media Database has been implemented using PostgreSQL with nine relational tables.

The design uses primary keys, foreign keys, composite keys, unique constraints, NOT NULL constraints and CHECK constraints to maintain data integrity.

Many-to-many relationships are represented using junction tables, while self-referencing relationships support follows and threaded comments.

The database successfully loaded 1,198,446 records across all nine tables. Independent row-count verification and three integrity checks returned the expected results.

The schema provides a structured relational foundation for the subsequent query workload, indexing and performance evaluation phases of the project.
