# Baseline Timings

Execution times are in milliseconds. Average values are from `benchmarks/results/baseline/summary.csv`.

| SQL Query | Type | Run 1 (ms) | Run 2 (ms) | Run 3 (ms) | Average (ms) |
|---|---|---:|---:|---:|---:|
| R01: Home feed: latest 30 posts from followed accounts | READ | 7.841 | 6.128 | 5.924 | 6.631 |
| R02: Profile grid: latest 12 posts | READ | 3.141 | 2.884 | 2.611 | 2.879 |
| R03: Open a profile by username | READ | 0.034 | 0.023 | 0.022 | 0.026 |
| R04: Post page: top-level comments and reply counts | READ | 9.896 | 7.291 | 7.476 | 8.221 |
| R05: Explore: top posts tagged #travel in June 2026 | READ | 9.501 | 9.086 | 9.191 | 9.259 |
| R06: Search accounts by username prefix or name | READ | 17.184 | 17.041 | 17.286 | 17.170 |
| R07: “Liked by”: likers and whether user 1042 follows them | READ | 8.441 | 5.804 | 6.859 | 7.035 |
| R08: Suggested accounts: friends of friends | READ | 0.170 | 0.123 | 0.119 | 0.137 |
| R09: Pending follow requests for account 338 | READ | 2.666 | 2.328 | 2.380 | 2.458 |
| R10: Stories from followed accounts in June 2026 | READ | 2.153 | 1.963 | 1.982 | 2.033 |
| R11: Creator engagement rate for 2026 posts | READ | 5.621 | 5.202 | 5.412 | 5.412 |
| R12: Trending hashtags in the last 7 days of June 2026 | READ | 3.165 | 2.935 | 3.045 | 3.048 |
| R13: Comments on post 59689 with no replies | READ | 21.975 | 23.252 | 21.457 | 22.228 |
| R14: Accounts that follow user 217 whom 217 doesn’t follow back | READ | 2.474 | 2.406 | 2.298 | 2.393 |
| R15: Verified or creator accounts with incorrect follower counts | READ | 29.247 | 28.384 | 29.716 | 29.116 |
| R16: Posts with a Goa location in June 2026 | READ | 6.606 | 6.508 | 6.631 | 6.582 |
| R17: Creators’ reels longer than 60 seconds, posted in 2026 | READ | 9.655 | 8.520 | 8.455 | 8.877 |
| R18: New posts per day and type in June 2026 | READ | 4.354 | 4.234 | 4.215 | 4.268 |
| R19: Verified accounts’ last post time and total likes received | READ | 5376.145 | 5475.973 | 5541.987 | 5464.702 |
| R20: Ten most-commented posts of June 2026 | READ | 13.315 | 13.596 | 13.247 | 13.386 |
| R21: Ghost followers of user 217 | READ | 4.105 | 4.120 | 4.497 | 4.241 |
| R22: Hidden comments, newest first, page 61 | READ | 6.958 | 7.596 | 5.621 | 6.725 |
| R23: Check whether user 1042 liked post 59689 | READ | 0.031 | 0.028 | 0.030 | 0.030 |
| R24: Total story views per account in the last 30 days | READ | 1.425 | 1.503 | 1.449 | 1.459 |
| W01: Publish a new photo post | WRITE | 0.556 | 0.392 | 0.425 | 0.458 |
| W02: User 1042 likes post 59689 | WRITE | 0.749 | 0.480 | 0.610 | 0.613 |
| W03: Update the counter after the like | WRITE | 0.301 | 0.120 | 0.126 | 0.182 |
| W04: Recompute every user’s follower count | WRITE | 63.195 | 64.566 | 64.736 | 64.166 |
| W05: Delete stories that expired before June 2026 | WRITE | 6.614 | 6.523 | 6.470 | 6.536 |
| W06: Accept pending follow requests for account 338 | WRITE | 2.758 | 2.867 | 2.642 | 2.756 |
