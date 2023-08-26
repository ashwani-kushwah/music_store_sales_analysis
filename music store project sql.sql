--In depth Exploratory Data Analysii (EDA) of sales data using the following set of questions.


--Question Set 1 - Easy

--1. Who is the senior most employee based on job title?
select top 1 * from employee
order by levels desc


--2. Which countries have the most Invoices?
select billing_country , count(invoice_id) No_of_invoices
from invoice
group by billing_country
order by No_of_invoices desc


--3. What are top 3 values of total invoice?
select top  3 total from invoice
order by total desc


--4. Which city has the best customers? We would like to throw a promotional Music 
--   Festival in the city we made the most money. Write a query that returns one city that 
--   has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
select top 1 billing_city, sum(total) City_total
from invoice
group by billing_city
order by City_total desc


--5. Who is the best customer? The customer who has spent the most money will be 
--   declared the best customer. Write a query that returns the person who has spent the most money
select top 1 c.customer_id, CONCAT(c.first_name,' ', c.last_name) Full_Name, sum(i.total) Total_spent
from customer c, invoice i
where c.customer_id = i.customer_id
group by c.customer_id, CONCAT(c.first_name,' ', c.last_name)
order by Total_spent desc




--Question Set 2 - Moderate

--1. Write query to return the email, first name, last name, & Genre of all Rock Music 
--   listeners. Return your list ordered alphabetically by email starting with A
select distinct c.email, c.first_name, c.last_name, g.name
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join genre g on t.genre_id = g.genre_id
where g.genre_id = 1
order by c.email


--2. Let's invite the artists who have written the most rock music in our dataset. Write a 
--   query that returns the Artist name and total track count of the top 10 rock bands
select top 10 at.artist_id, at.name, count(at.artist_id) as Track_Count
from track t
join album a on t.album_id = a.album_id
join artist at on a.artist_id = at.artist_id
join genre g on g.genre_id = t.genre_id
where g.name like 'Rock'
group by at.artist_id, at.name
order by Track_Count desc



--3. Return all the track names that have a song length longer than the average song length. 
--   Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
select Name, milliseconds
from track
where milliseconds > (
	select AVG(milliseconds) Avg_track_length
	from track)
order by milliseconds desc;








--Question Set 3 - Advance

--1. Find how much amount spent by each customer on artists? Write a query to return
--   customer name, artist name and total spent
with cte as (
	select top 1 at.artist_id ArtistId, at.name ArtistName, SUM(il.quantity*il.unit_price) Total
	from invoice_line il
	join track t on t.track_id = il.track_id
	join album a on a.album_id = t.album_id
	join artist at on at.artist_id = a.artist_id
	group by at.artist_id, at.name
	order by 3 desc
)
select c.customer_id, c.first_name, c.last_name, cte.ArtistName, SUM(il.quantity*il.unit_price) TotalAmount
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album a on a.album_id = t.album_id
join cte on cte.ArtistId = a.artist_id
group by c.customer_id, c.first_name, c.last_name, cte.ArtistName
order by TotalAmount desc;



--2. We want to find out the most popular music Genre for each country. We determine the most popular genre as the 
--   genre with the highest amount of purchases. Write a query that returns each country along with the top Genre.
--   For countries where the maximum  number of purchases is shared return all Genres
with cte as (
	select c.country CountryName, g.name, COUNT(il.quantity) NoOfPurchases,
	ROW_NUMBER() over(partition by c.country order by COUNT(il.quantity) desc) rnk
	from invoice_line il
	join invoice i on i.invoice_id = il.invoice_id
	join customer c on c.customer_id = i.customer_id
	join track t on t.track_id = il.track_id
	join genre g on g.genre_id = t.genre_id
	group by c.country, g.name
)
select * from cte
where rnk<=1;




--3. Write a query that determines the customer that has spent the most on music for each country. 
--   Write a query that returns the country along with the top customer and how much they spent. 
--   For countries where the top amount spent is shared, provide all customers who spent this amount
with cte as (
	select billing_country, c.first_name, c.last_name, c.customer_id, SUM(total) AmountSpent,
	DENSE_RANK() over(partition by billing_country order by SUM(total) desc) rnk
	from customer c
	join invoice i on c.customer_id = i.customer_id
	group by billing_country, c.first_name, c.last_name, c.customer_id
)
select * from cte
where rnk <=1



--with recursive cte as(
--	select c.customer_id, c.first_name, c.last_name, billing_country, SUM(total) AmountSpent
--	from customer c
--	join invoice i on c.customer_id = i.customer_id
--	group by c.customer_id, c.first_name, c.last_name, billing_country, 
	
--	max_spent as (
--	select billing_country, MAX(AmountSpent) MaxSpent
--	from cte
--	group by billing_country)

--select cte.billing_country, cte.AmountSpent, cte.first_name, cte.last_name
--from cte
--join max_spent ms
--on cte.billingcountry = ms.billingcountry
--where cte.AmountSpent = ms.MaxSpent
