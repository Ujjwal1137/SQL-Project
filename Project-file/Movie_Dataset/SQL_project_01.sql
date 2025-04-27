create database project_01;
use project_01;
-- drop database project_01;
-- create table dataset(name int);
-- drop table movie_name;

select * from actor_movies limit 20;
select * from actors limit 20;
select * from movie_genres limit 20;
select * from movie_languages limit 20;
select * from movies limit 50;
-- select * from movie_name limit 50;
/*


Q1 which cinema launched highest movies in year 2020 to 2022 and duration more than 100 mins (peak covid time)
Q2 what is the avg duration of time most movies are launched with 
Q3 name the actor and movie which is related to classification adult show top 5 
Q4 In Which year most of action movies are launched 
Q5 top 5 actors with hightest movie count in hindi and punjabi language 
Q6 Rank actors with movies released in Hindi based on their average duration minutes. Which actor is at the top of the list?
Q7 What is the genre-wise average movie duration and list of language they are released with?
Q8 which actor has done movies with highest number of genres 
Q9 list of movies launched by hindi cinema and have more than 3 languages 
Q10 list top 2 movies with highest movie duration and in which year it is launched
Q11 select movie , actors , cinema, genres and languages of the longest movie of year 2025 to 2023 top 3
Q12 Which are the top two cinema houses that have produced the highest number of movies among multilingual movies?
Q13 Find the total number of movies released each year? How does the trend look month wise?
Q14 Find the count unique list of the genres and languages present in the data set?
		rewrite and arrange them according to the lvl or query and check older project of sql and movie related 
											***********************************************
M1. Which cinema house released the most movies between 2020 and 2022, with durations over 120 minutes (during the COVID peak years)?
E1. What is the average duration of movies across all releases?
M2. Which actors have appeared in the highest number of movies classified as A (Adult)?List the top 5 actors along with the names of those movies.?
M3. In which year were the most action movies released?
M4. Who are the top 5 actors with the highest number of movie releases in Hindi and Punjabi languages?
H1. Rank Hindi film actors based on the average duration of their movies. Which actor tops the list?
M5. What is the average movie duration for each genre, and in which languages are they released?
8. Which actor has worked in the highest number of unique genres?
9. List all Hindi-cinema movies that have been released in more than three languages.
H2. Which are the top 2 longest-duration movies, and in which years were they released?
H3. For the top 2 longest movies released between 2020 and 2025, list the movie name, actors, cinema house, genres, and languages.
H4 .Which five cinema houses have produced the highest number of multilingual movies?
E2. What is the total number of movies released each year? Additionally, what does the yearly trend look like for these releases?
E3. Provide a count of all unique genres and languages present in the dataset.	
  #can add count column or max statement for easy question 			
*/

-- ans M 1
-- Which cinema house released the most movies between 2020 and 2022, with durations over 120 minutes (during the COVID peak years)?

SELECT cinema, COUNT(movie_name) AS total_movies
FROM movies
WHERE duration_minutes > 120 AND YEAR(release_date) IN (2020 , 2021, 2022)
GROUP BY cinema ORDER BY total_movies DESC;

-- ans E 1
select * from movies limit 50;
Select avg(duration_minutes) as average_duration from movies;

-- ans M2
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

-- ans M3
SELECT YEAR(release_date) AS 'Year', COUNT(m.movie_id) No_of_Action_Movies
FROM movies m
JOIN movie_genres mg ON m.movie_id = mg.movie_id
WHERE mg.genre = 'Action'
GROUP BY Year ORDER BY No_of_Action_Movies DESC;

  -- ans M4
SELECT a.actor_name, COUNT(m.movie_id) AS No_Of_Movies
FROM movies m
JOIN actor_movies am ON m.movie_id = am.movie_id
JOIN actors a ON a.actor_id = am.actor_id 
JOIN movie_languages ml ON m.movie_id = ml.movie_id
WHERE ml.language = 'Punjabi' OR 'Hindi'
GROUP BY a.actor_name  
ORDER BY No_Of_Movies DESC LIMIT 5; 

-- ans H1  Rank Hindi film actors based on the average duration of their movies. Which actor tops the list?

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


-- M5
SELECT mg.genre, AVG(m.duration_minutes) AS avg_duration, 
    GROUP_CONCAT(DISTINCT ml.language ORDER BY ml.language SEPARATOR ', ') AS languages
FROM movies m 
JOIN movie_genres mg ON m.movie_id = mg.movie_id
JOIN movie_languages ml ON m.movie_id = ml.movie_id
GROUP BY mg.genre  
ORDER BY avg_duration DESC limit 20; 

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

-- E2. What is the total number of movies released each year? Additionally, what does the yearly trend look like for these releases ?
SELECT YEAR(Release_date) Year, COUNT(movie_id) no_of_movies
FROM movies
GROUP BY year
ORDER BY year DESC;

-- E3. Provide a count of all unique languages present in the dataset.	
SELECT COUNT(DISTINCT (language)) Total_Distinct_languages
FROM movie_languages;

-- E4 "Which movie classification has the highest number of movies?"
SELECT classification, COUNT(*) AS movie_count
FROM movies
GROUP BY classification
ORDER BY movie_count DESC;

-- E5 Find out the Total No of Actors from the Dataset 
SELECT COUNT(DISTINCT (Actor_name)) No_of_Actors
FROM actors;

-- List the details of movies where the name starts with 'Baahubali'."

SELECT movie_name, cinema, release_date, duration_minutes
FROM movies
WHERE movie_name LIKE 'Baahubali%';

-- E1 List the details of Top-12 movies that have released a second part (sequel)."

SELECT movie_name, cinema, date(release_date) release_date, duration_minutes
FROM movies
WHERE movie_name LIKE '% 2%'
LIMIT 12;

-- ** list all the names of actors who worked in movie "name" 

--  Find nice PPT BG from canva or similar site 


