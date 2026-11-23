# Scalability Report

## 1. Objective

This report describes how the Instagram database can scale as data volume and query workload increase.

## 2. Partitioning Strategy

The `likes` table is a candidate for partitioning because it can contain a large number of records.

We selected HASH partitioning on `post_id`.

### Configuration

- Parent table: `instagram.likes_partitioned`
- Partition key: `post_id`
- Partitioning method: HASH
- Number of partitions: 8
- Partitions: `likes_p0` to `likes_p7`

### Reason for Selection

Likes are associated with posts. HASH partitioning distributes records across partitions based on the hash of `post_id`.

This helps distribute storage and index workload across multiple partitions.

## 3. Partition Pruning

We tested partition pruning using:

```sql
EXPLAIN
SELECT *
FROM instagram.likes_partitioned
WHERE post_id = 100;
```

The query plan accessed only `likes_p1`, rather than scanning all eight partitions.

This demonstrates partition pruning: PostgreSQL eliminates partitions that cannot contain matching rows.

## 4. Data Distribution Test

We inserted 100 records from the original likes table into the partitioned table.

The records were distributed as follows:

| Partition | Rows |
|---|---:|
| likes_p0 | 15 |
| likes_p1 | 13 |
| likes_p2 | 11 |
| likes_p3 | 13 |
| likes_p4 | 11 |
| likes_p5 | 12 |
| likes_p6 | 8 |
| likes_p7 | 17 |
| **Total** | **100** |

The distribution is not perfectly equal because hash partitioning distributes rows according to hash values.

## 5. Primary Key Consideration

PostgreSQL requires a partitioned table's primary key or unique constraint to include all partition-key columns.

Our primary key is:

`PRIMARY KEY (user_id, post_id)`

Since `post_id` is included, it satisfies this requirement.

## 6. Scaling Considerations

For a significantly larger dataset:

- Monitor query execution plans and partition sizes.
- Use appropriate indexes on frequently queried columns.
- Run ANALYZE after large data loads.
- Evaluate partition count based on actual workload.
- Consider read replicas and connection pooling for higher read traffic.
- Monitor storage, memory, CPU and query latency.

## 7. Limitations

- HASH partitioning does not guarantee perfectly equal partition sizes.
- Queries that do not filter on `post_id` may need to scan multiple partitions.
- Increasing the number of partitions later requires careful migration planning.
- Partitioning does not automatically make every query faster.
- Performance improvements must be verified using representative datasets and benchmarks.

## 8. Conclusion

HASH partitioning on `post_id` provides a way to distribute likes records across eight partitions.

Our EXPLAIN test demonstrated partition pruning for a query filtering by `post_id`.

Further benchmarking on a larger dataset is needed to quantify the performance benefits.
