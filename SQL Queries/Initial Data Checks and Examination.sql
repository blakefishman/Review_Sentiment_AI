-- Examining analyzed dataset in Google BigQuery and performing checks for duplicates, errors, inconsistencies, ranges, etc. to ensure integrity of the AI's analysis.


-- 1) Duplicate reviews check

SELECT
    id,
    COUNT(*) AS duplicate_id_count
FROM `core.reviews_analyzed`
GROUP BY 1
HAVING duplicate_id_count > 1
;


-- 2) Null check

SELECT
    SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS null_count_id,
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS null_count_date,
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS null_count_rating,
    SUM(CASE WHEN product IS NULL THEN 1 ELSE 0 END) AS null_count_product,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS null_count_category,
    SUM(CASE WHEN comments IS NULL THEN 1 ELSE 0 END) AS null_count_comments,
    SUM(CASE WHEN sentiment IS NULL THEN 1 ELSE 0 END) AS null_count_sentiment,
    SUM(CASE WHEN confidence IS NULL THEN 1 ELSE 0 END) AS null_count_confidence,
    SUM(CASE WHEN rating_consistency IS NULL THEN 1 ELSE 0 END) AS null_count_rating_consistency,
    SUM(CASE WHEN main_topic IS NULL THEN 1 ELSE 0 END) AS null_count_main_topic,
    SUM(CASE WHEN secondary_topic IS NULL THEN 1 ELSE 0 END) AS null_count_secondary_topic,
    SUM(CASE WHEN emotion IS NULL THEN 1 ELSE 0 END) AS null_count_emotion,
    SUM(CASE WHEN action_needed IS NULL THEN 1 ELSE 0 END) AS null_count_action_needed,
    SUM(CASE WHEN drafted_response IS NULL THEN 1 ELSE 0 END) AS null_count_drafted_response,
    SUM(CASE WHEN sentiment_category IS NULL THEN 1 ELSE 0 END) AS null_count_sentiment_category
FROM `core.reviews_analyzed`
;


-- 3) Empty check for strings

SELECT
    SUM(CASE WHEN TRIM(product) = '' THEN 1 ELSE 0 END) AS empty_count_product,
    SUM(CASE WHEN TRIM(category) = '' THEN 1 ELSE 0 END) AS empty_count_category,
    SUM(CASE WHEN TRIM(comments) = '' THEN 1 ELSE 0 END) AS empty_count_comments,
    SUM(CASE WHEN TRIM(main_topic) = '' THEN 1 ELSE 0 END) AS empty_count_main_topic,
    SUM(CASE WHEN TRIM(secondary_topic) = '' THEN 1 ELSE 0 END) AS empty_count_secondary_topic,
    SUM(CASE WHEN TRIM(emotion) = '' THEN 1 ELSE 0 END) AS empty_count_emotion,
    SUM(CASE WHEN TRIM(action_needed) = '' THEN 1 ELSE 0 END) AS empty_count_action_needed,
    SUM(CASE WHEN TRIM(drafted_response) = '' THEN 1 ELSE 0 END) AS empty_count_drafted_response,
    SUM(CASE WHEN TRIM(sentiment_category) = '' THEN 1 ELSE 0 END) AS empty_count_sentiment_category
FROM `core.reviews_analyzed`
;


-- 4) Check product, category, emotion, and sentiment_category for inconsistencies and typos

SELECT
    DISTINCT product,
    COUNT(product) AS count
FROM `core.reviews_analyzed`
GROUP BY 1
ORDER BY 1
;

SELECT
    DISTINCT category,
    COUNT(category) AS count
FROM `core.reviews_analyzed`
GROUP BY 1
ORDER BY 1
;

SELECT
    DISTINCT emotion,
    COUNT(emotion) AS count
FROM `core.reviews_analyzed`
GROUP BY 1
ORDER BY 1
;

SELECT
    DISTINCT sentiment_category,
    COUNT(sentiment_category) AS count
FROM `core.reviews_analyzed`
GROUP BY 1
ORDER BY 1
;


-- 5) Examine rating, sentiment, and confidence to verify ranges and check for outliers

SELECT
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating,
    STDDEV(rating) AS stddev_rating,
    MIN(sentiment) AS min_sentiment,
    MAX(sentiment) AS max_sentiment,
    AVG(sentiment) AS avg_sentiment,
    STDDEV(sentiment) AS stddev_sentiment,
    MIN(confidence) AS min_confidence,
    MAX(confidence) AS max_confidence,
    AVG(confidence) AS avg_confidence,
    STDDEV(confidence) AS stddev_confidence
FROM `core.reviews_analyzed`
;


-- 6) Check id and date ranges for outliers

SELECT
    MIN(id) AS min_id,
    MAX(id) AS max_id,
    MIN(date) AS min_date,
    MAX(date) AS max_date
FROM `core.reviews_analyzed`
;


-- 7) Verify 0/1 binary for rating_consistency

SELECT
    COUNT(rating_consistency)
FROM `core.reviews_analyzed`
WHERE rating_consistency IS NULL
    OR rating_consistency NOT IN (0, 1)
;