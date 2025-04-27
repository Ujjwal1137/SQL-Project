
create database project_01;
use project_01;

-- -------------------------------------------------   EASY  ------------------------------------------------------------------------------------

-- E1 List the details of Top-12 movies that have released a second part (sequel).
SELECT movie_name, cinema, date(release_date) release_date, duration_minutes
FROM movies
WHERE movie_name LIKE '% 2%'
LIMIT 12;

-- E2. What is the total number of movies released each year? Additionally, what does the yearly trend look like for these releases?
SELECT YEAR(Release_date) Year, COUNT(movie_id) no_of_movies
FROM movies
GROUP BY year
ORDER BY year DESC;

-- E3. List the details of movies where the name starts with 'Baahubali'.
SELECT movie_name, cinema, release_date, duration_minutes
FROM movies
WHERE movie_name LIKE 'Baahubali%';

-- E4 Find out the Total No of Actors from the Dataset 
SELECT COUNT(DISTINCT (Actor_name)) No_of_Actors
FROM actors;

-- E5 Which movie classification has the highest number of movies?
SELECT classification, COUNT(*) AS movie_count
FROM movies
GROUP BY classification
ORDER BY movie_count DESC;

-- -------------------------------------------------   Moderate  ------------------------------------------------------------------------------------

-- M1 Which cinema house released the most movies between 2020 and 2022, with durations over 120 minutes (during the COVID peak years)?
SELECT cinema, COUNT(movie_name) AS total_movies
FROM movies
WHERE duration_minutes > 120 AND YEAR(release_date) IN (2020 , 2021, 2022)
GROUP BY cinema ORDER BY total_movies DESC;

-- M2. Which actors have appeared in the highest number of movies classified as A (Adult)?List the top 5 actors along with the names of those movies.?
SELECT 
    a.actor_name, 
    COUNT(m.movie_id) AS No_Of_Movies,
    group_CONCAT(m.movie_name SEPARATOR ', ') AS movie_list
FROM movies m
JOIN actor_movies am ON m.movie_id = am.movie_id
JOIN actors a ON a.actor_id = am.actor_id 
WHERE m.classification = 'A'
GROUP BY a.actor_name  
ORDER BY No_Of_Movies DESC LIMIT 5; 

-- M3. In which year were the most action movies released?
SELECT YEAR(release_date) AS 'Year', COUNT(m.movie_id) No_of_Action_Movies
FROM movies m
JOIN movie_genres mg ON m.movie_id = mg.movie_id
WHERE mg.genre = 'Action'
GROUP BY Year ORDER BY No_of_Action_Movies DESC;

-- M4. Who are the top 5 actors with the highest number of movie releases in 'Hindi' and 'Punjabi' languages?
SELECT a.actor_name, COUNT(m.movie_id) AS No_Of_Movies
FROM movies m
JOIN actor_movies am ON m.movie_id = am.movie_id
JOIN actors a ON a.actor_id = am.actor_id 
JOIN movie_languages ml ON m.movie_id = ml.movie_id
WHERE ml.language = 'Punjabi' OR 'Hindi'
GROUP BY a.actor_name  
ORDER BY No_Of_Movies DESC LIMIT 5; 

-- M5. What is the average movie duration for each genre, and in which languages are they released?
SELECT mg.genre, AVG(m.duration_minutes) AS avg_duration, 
    GROUP_CONCAT(DISTINCT ml.language ORDER BY ml.language SEPARATOR ', ') AS languages
FROM movies m 
JOIN movie_genres mg ON m.movie_id = mg.movie_id
JOIN movie_languages ml ON m.movie_id = ml.movie_id
GROUP BY mg.genre  
ORDER BY avg_duration DESC limit 20; 

-- -------------------------------------------------   HARD  ------------------------------------------------------------------------------------

-- H1.  Rank Hindi film actors based on the average duration of their movies. Which actor tops the list?
SELECT a.actor_name, ROUND(AVG(m.duration_minutes)) AS avg_duration,
    DENSE_RANK() OVER (ORDER BY AVG(m.duration_minutes) DESC) AS Ranks
FROM movies m
JOIN actor_movies am ON m.movie_id = am.movie_id
JOIN actors a ON a.actor_id = am.actor_id 
JOIN movie_languages ml ON m.movie_id = ml.movie_id
WHERE ml.language = 'Hindi'
GROUP BY a.actor_name  
ORDER BY Ranks ASC
LIMIT 5;

-- H2 Which are the top 2 longest-duration movies, and in which years were they released?
with movie_temp as (select movie_name, duration_minutes, release_date, 
rank() over (order by duration_minutes DESC) rnk from movies) 
select Movie_name, Duration_minutes, 
YEAR(release_date) as Released_Year from movie_temp
where rnk <=2;

-- H3  For the top 2 longest movies released between 2020 to 2025, list the movie name, actors, cinema house, genres, and languages.
WITH movie_temp AS (
    SELECT m.movie_id, m.movie_name, m.cinema,m.duration_minutes,m.release_date,
	RANK() OVER (ORDER BY m.duration_minutes DESC) AS rnk
    FROM movies m
    WHERE YEAR(m.release_date) IN (2020, 2021, 2022, 2023, 2024, 2025) )
SELECT mt.Movie_name,mt.Cinema,mt.Duration_minutes,
    YEAR(mt.release_date) AS Released_year,
    GROUP_CONCAT(DISTINCT a.actor_name ORDER BY a.actor_name SEPARATOR ', ') AS Actors,
    GROUP_CONCAT(DISTINCT mg.genre ORDER BY mg.genre SEPARATOR ', ') AS Genres,
    GROUP_CONCAT(DISTINCT ml.language ORDER BY ml.language SEPARATOR ', ') AS Languages
FROM movie_temp mt
JOIN actor_movies am ON mt.movie_id = am.movie_id
JOIN actors a ON a.actor_id = am.actor_id
JOIN movie_genres mg ON mt.movie_id = mg.movie_id
JOIN movie_languages ml ON mt.movie_id = ml.movie_id
WHERE mt.rnk <= 2
GROUP BY mt.movie_id, mt.movie_name, mt.cinema, mt.duration_minutes, mt.release_date
ORDER BY mt.duration_minutes DESC;

-- H4 .Which top five cinema houses have produced the highest number of movies released in more than two languages?
SELECT cinema, COUNT(*) AS multilingual_movie_count
FROM (SELECT m.movie_id, m.cinema,
CASE 
WHEN COUNT(DISTINCT ml.language) > 2 THEN 1
ELSE 0
END AS is_multilingual
FROM movies m
JOIN movie_languages ml ON m.movie_id = ml.movie_id
GROUP BY m.movie_id, m.cinema) AS movie_multilingual
WHERE is_multilingual = 1
GROUP BY cinema
ORDER BY multilingual_movie_count DESC
LIMIT 5;

-- -------------------------------------------------   END  ------------------------------------------------------------------------------------