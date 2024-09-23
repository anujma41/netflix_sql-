SELECT * FROM netflix;
--Count the number of Movies vs TV Shows
SELECT type,
count(*) as total
from netflix
GROUP BY type;

--Find the most common rating for movies and TV shows
select type,rating,total
from
(SELECT type,rating,
count(*)as total,
rank() over(partition by type order by count(*)desc)as rank
from netflix
group by type,rating)
as hg
where rank=1;

--List all movies released in a specific year (e.g., 2021)
SELECT type,release_year
FROM netflix
where type='Movie'
and release_year=2021;


--. Find the top 5 countries with the most content on Netflix
select 
unnest(string_to_array(country,','))as new_country,
count(show_id)as total_content
from netflix
group by country
order by total_content desc
limit 5;

--Identify the longest movie
select duration,title,type,count(*)as total
from netflix
where type='Movie'
group by duration,type,title
order by duration desc;

--Find content added in the last 5 years
select release_year,title
from netflix
WHERE 
release_year>= 2017
group by release_year,title
order by release_year desc;

--Find all the movies/TV shows by director 'Rajiv Chilaka'!
select type,title,new_name
from
(select type,title,
unnest(STRING_TO_ARRAY(director,','))as new_name
from netflix) as j
where new_name ='Rajiv Chilaka';
--or
select * from netflix
where director like '%Rajiv Chilaka';

--List all TV shows with more than 5 seasons
select type,title,SPLIT_PART(duration,' ',1) as season
from netflix
where
type='TV Show'
AND
 SPLIT_PART(duration,' ',1)::numeric > 5; 

-- Count the number of content items in each genre
select 
unnest(STRING_TO_ARRAY(listed_in,',')) as genre,
count(show_id) as total
from netflix
group by genre;

--(Find each year and the average numbers of content release in India on netflix. 
 --return top 5 year with highest avg content release!)
SELECT
extract(year from to_date(date_added,'month DD,yyyy'))as year,
count(*)as yearly_content,
count(*)::numeric/(select count(*)from netflix where country='India')::numeric*100 as avg_content
FROM netflix
where country='India'
group by 1
order by 3 desc
limit 5;

--List all movies that are documentaries
select listed_in,title from netflix
where listed_in like '%Documentaries';

--Find all content without a director
select type,title,director from netflix
where
director is null;

--Find how many movies actor 'Salman Khan' appeared in last 10 years!
select title,casts,release_year from netflix
where casts Ilike '%salman khan%'
and release_year< extract(year from current_date)-10;

--Find the top 10 actors who have appeared in the highest number of movies produced in India.
select 
unnest(string_to_array(casts,','))as actors,
count(*)as total
from netflix
where type='Movie'
and country ilike  '%India%'
group by 1
order by total desc;

--Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.
WITH new_table AS (
    SELECT *, 
           CASE
               WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'bad_content'
               ELSE 'good'
           END AS category
    FROM netflix
)
SELECT category, 
       COUNT(*) AS total_count
FROM new_table
GROUP BY category;

