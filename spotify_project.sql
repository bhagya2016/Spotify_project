-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

--EDA
--1.Count of records
select count(*) from spotify;  --20594
--2.Count of Artists
select count(distinct artist) 
from spotify; --2074
--3.Count of Albums
select count(distinct album)
from spotify; --11854
--4.Count of Album type
select count(distinct album_type)
from spotify; --3
--5.Max duration of album
select max(duration_min)
from spotify; --77.9
--6.Min duration of album
select min(duration_min)
from spotify; --0
--7.Min duration cant be 0 checking the records and deleting them
select *
from spotify
where duration_min=0;
delete
from spotify
where duration_min=0;
--8.Checking if records are deleted
select *
from spotify
where duration_min=0;
--9.How many channel
select 
count(distinct channel)
from spotify; --6673
--10.Max views
select
max(views) 
from spotify; --8079649362
--11.Min views
select
min(views)
from spotify; --0
--12.artist and album with no views and no likes
select *
from spotify
where views=0 and likes=0;--Wisin & Yandel
--13.Songs are played on which platforms
select distinct most_played_on
from spotify; --Youtube and spotify


-- --------------------------------------
-- Data Analysis
-- --------------------------------------
--Q1.Retrieve the names of all tracks that have more than 1 billion streams.
select track
from spotify
where stream>1000000000 --around 350 records

--Q2.List all albums along with their respective artists.
select distinct album,artist
from spotify;

--Q3.Get the total number of comments for tracks where licensed = TRUE.
select track,total(comments) as Total_comments
from spotify
where licensed=True
group by track
order by Total_comments desc;

--Q4.Find all tracks that belong to the album type single.
select track
from spotify
where album_type='single';

--Q5.Count the total number of tracks by each artist.
select artist,count(track) as Total_tracks
from spotify
group by artist;

--Q6.Calculate the average danceability of tracks in each album.
select album,avg(danceability) as avg_danceability
from spotify
group by album
order by 2 desc;

--Q7.Find the top 5 tracks with the highest energy values.
select track,energy as energy_track
from spotify
group by track
order by 2 desc
limit 5;

--Q8.List all tracks along with their views and likes where official_video = TRUE.
select track,
sum(views) as total_views,
sum(likes) as total_likes
from spotify
where official_video='True'
group by track;

--Q9.For each album, calculate the total views of all associated tracks.
select album,
track,
sum(views) as Total_views
from spotify
group by album,track
order by 2 desc;

--Q10.Retrieve the track names that have been streamed on Spotify more than YouTube.
select * from
(select track,
coalesce(sum(case when most_played_on='Spotify' then stream end),0) as streaming_at_spotify,
coalesce(sum(case when most_played_on='Youtube' then stream end),0) as streaming_at_youtube
from spotify
group by 1) as t
where streaming_at_spotify>streaming_at_youtube
and streaming_at_youtube<>0;

--Q11.Find the top 3 most-viewed tracks for each artist using window functions.
with cte as(
select artist,
track,
sum(views) as total_views,
dense_rank() over(partition by artist order by sum(views)) as rnk
from spotify
group by 1,2
order by 1,3 desc)
select artist,
track,
total_views
from cte
where rnk<4;

--Q12.Write a query to find tracks where the liveness score is above the average.
select track,
avg(liveness) as avg_liveness
from spotify
group by 1
having avg(liveness)>(select avg(liveness) from spotify)

--Q13.Use a WITH clause to calculate the difference between the highest and 
--lowest energy values for tracks in each album.
with cte as(
select album,
max(energy) as max_energy,
min(energy) as min_energy
from spotify
group by album)
select album,
max_energy-min_energy as difference
from cte

--Q14.Find tracks where the energy-to-liveness ratio is greater than 1.2.
select distinct track
from spotify
where energy/liveness>1.2;
--Q15.Calculate the cumulative sum of likes for tracks ordered by the number of views,
--using window functions.
WITH cte AS (
    SELECT 
        track,
        SUM(views) AS total_views,
        SUM(likes) AS total_likes
    FROM spotify
    GROUP BY track
)

SELECT 
    track,
    total_views,
    total_likes,

    SUM(total_likes) OVER (
        ORDER BY total_views DESC
    ) AS cumulative_sum

FROM cte;














