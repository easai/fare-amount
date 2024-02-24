CREATE OR REPLACE VIEW
  fare_tip_view AS
WITH
  TipRate AS(
  SELECT
    AVG(tip_amount/trip_distance) AS tip_rate
  FROM
    `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2021`
  WHERE
    trip_distance > 0 )
SELECT
  vendor_id,
  
  CASE
    WHEN trip_distance < 25 THEN CAST(fare_amount AS FLOAT64)
  ELSE
    CAST(SAFE_ADD(fare_amount, extra) AS FLOAT64)
  END AS fare_amount,

  CAST(tip_amount AS FLOAT64) AS tip_amount,
  CAST(trip_distance AS FLOAT64) AS trip_distance

FROM
  `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2021`
WHERE
  tip_amount > (
  SELECT
    tip_rate
  FROM
    TipRate )*trip_distance
LIMIT 100
