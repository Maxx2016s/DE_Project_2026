# Instagram Social Media Database — Problem Understanding

## 1. Business Context

Instagram relies on a social graph connecting users through follows, posts, likes, comments, hashtags and stories. The existing database has an undocumented structure and performance problems affecting feed delivery, social interactions, search, creator insights and analytics.

The objective is to reconstruct a well-constrained PostgreSQL database, measure the performance of 30 important queries, optimize them without changing their results, and evaluate scalability at 20× data volume.

## 2. Business Problems and Stakeholders

| ID | Business Need | Affected Stakeholder | Classification |
|---|---|---|---|
| P1 | Deliver the home feed and profile grid quickly, even for accounts following many users. | End users, Feed team | Customer-facing / Real-time |
| P2 | Load post comments, reply counts, liked-by lists and like-button state efficiently on popular posts. | End users, Post page team | Customer-facing / Real-time |
| P3 | Make hashtag, account and location search responsive. | End users, Explore and Search teams | Customer-facing / Real-time |
| P4 | Generate account suggestions and display pending follow requests efficiently. | End users, Social graph team | Customer-facing / Real-time |
| P5 | Provide creators with engagement rates, ghost-follower information, follow-back status and reels performance. | Creators | Reporting / Analytics |
| P6 | Correctly identify comments that have not received replies. | Creators | Customer-facing / Real-time |
| P7 | Detect inaccurate stored follower counts and support efficient counter-recalculation jobs. | Data quality team, Creators | Reporting / Analytics |
| P8 | Improve story highlights, story insights, expired-story cleanup and moderation-console performance. | End users, Trust and Safety team | Mixed: Real-time and Batch processing |
| P9 | Support content analytics and reporting as engagement and data volume grow by 20×. | Growth analytics team | Reporting / Analytics |

## 3. Performance Priorities

- Customer-facing operations require low latency because users interact with them directly.
- Search and creator tools require responsive query execution.
- Reporting and analytics queries may process larger portions of the database and therefore need efficient aggregation.
- Batch operations such as counter recalculation and story cleanup must process large datasets efficiently.

## 4. Assumptions

1. Accepted follow relationships represent active follows.
2. Pending follow relationships represent requests awaiting approval.
3. A NULL `parent_comment_id` indicates a top-level comment.
4. Posts may contain multiple media items, particularly carousels.
5. Stories are intended to expire 24 hours after creation.
6. Stored counters are maintained for faster profile and post access, but may become inconsistent with the underlying