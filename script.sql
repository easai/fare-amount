-- This query calculates the average tip rates per distance and per fare amount within the fare amount group, and count the number of trips that exceeds the average by 30%.
WITH
  DistanceTip AS (
  -- Calculates the average tip rates per distance.
  SELECT
    ROUND(trip_distance / 10) AS distance_group,
    AVG(tip_amount/trip_distance) AS avg_tip_per_distance
  FROM
    `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2021`
  WHERE
    trip_distance > 0
  GROUP BY
    distance_group ),
  FareTip AS (
  -- Calculates the average tip rates per fare amount.
  SELECT
    ROUND(fare_amount / 10) AS fare_group,
    AVG(tip_amount/fare_amount) AS avg_tip_per_fare
  FROM
    `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2021`
  WHERE
    fare_amount >0
  GROUP BY
    fare_group ),
  TipThreshold AS (
  -- Selects trips with tip amount exceeding the average amount by 30%.
  SELECT
    vendor_id,
    CASE
        WHEN
          tip_amount > (
          -- Select the average tip amount per distance for the distance group.
          SELECT
            avg_tip_per_distance
          FROM
            DistanceTip
          WHERE
            distance_group = ROUND(trip_distance / 10) ) * trip_distance * 1.3
    
          OR 

          tip_amount > (
          -- Select the average tip amount per fare amount for the fare amount group.
          SELECT
            avg_tip_per_fare
          FROM
            FareTip
          WHERE
            fare_group = ROUND(fare_amount / 10) ) * fare_amount * 1.3 
        THEN 1
        ELSE 0
    END
    AS tip_threshold_exceeded
  FROM
    `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2021` )
-- Count the total trips and the number of trips with exceeded tips
SELECT
  COUNT(*) AS total_trips,
  COUNTIF(tip_threshold_exceeded = 1) AS tip_threshold_exceeded_count
FROM
  TipThreshold