-- This query creates a view of the modified taxi fare of the trip whose tip amount is more than the average for the distance group.
CREATE OR REPLACE VIEW
  fare_tip_view AS
WITH
  TipRate AS(
  -- Create a CTE and calculate tip rates for each distance group. The distance group is defined by trip_distance divided by 10, rounded.
  SELECT
    ROUND(trip_distance / 10) AS distance_group,
    AVG(tip_amount/trip_distance) tip_rate
  FROM
    `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2021`
  WHERE
    trip_distance > 0
  GROUP BY
    distance_group )
-- In the main SELECT query, it selects vender_id, the modified fare_amount, tip_amount, and trip_distance. The query joins the TipRate table for the distance_group of the row and includes only the trip with tip_amount larger than the calculated tip amount.
SELECT
  vendor_id,
  CASE
    WHEN trip_distance < 25 THEN CAST(fare_amount AS FLOAT64)
  ELSE
  CAST(SAFE_ADD(fare_amount, extra) AS FLOAT64)
END
  AS fare_amount,
  CAST(tip_amount AS FLOAT64) AS tip_amount,
  CAST(trip_distance AS FLOAT64) AS trip_distance
FROM
  `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2021`
JOIN
  TipRate
ON
  distance_group = ROUND(trip_distance / 10) 
WHERE
  tip_amount > ( TipRate.tip_rate )*trip_distance