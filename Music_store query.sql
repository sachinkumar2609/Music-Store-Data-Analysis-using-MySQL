/*CREATING DATABASE Music_Store */

create database if not exists Music_Store;

/*USING DATABASE*/

use music_store;

/*solving questions of the company*/
/*Who is the senior most employee based on job title?*/
select *
from employee
order by levels desc, hire_date 
limit 1
;

/*Which countries have the most Invoices?*/
select billing_country, count(invoice_id) 
from invoice
group by billing_country
order by count(invoice_id) desc
limit 1
;

/*What are top 3 values of total invoice?*/
select * from invoice;
select * 
from invoice
order by total desc
limit 3;

/*Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals*/
select billing_city, sum(total)
from invoice
group by billing_city
order by sum(total) desc
limit 1;

/*Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money*/
select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total)
from customer
	inner join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by sum(invoice.total) desc
limit 1
;
SET @@sql_mode = REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''); /*if error of full group by while executing above query*/

/*Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A*/
select * from genre;
select distinct customer.email, customer.first_name, customer.last_name, genre.name
from ((((customer
	inner join invoice on customer.customer_id = invoice.customer_id)
    inner join invoice_line on invoice.invoice_id = invoice_line.invoice_id)
    inner join track on invoice_line.track_id = track.track_id)
	inner join genre on track.genre_id = genre.genre_id)
where genre.name = 'Rock'

order by customer.email
;

/*Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands*/
select artist.name, count(track.track_id) as track
from (((album
	inner join artist on artist.artist_id = album.artist_id)
    inner join track on track.album_id = album.album_id)
    inner join genre on genre.genre_id = track.genre_id)
where genre.name = 'Rock'
group by artist.artist_id
order by track desc 
limit 10;

/*Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first*/

select name, milliseconds
from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;

/*Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent*/
select 
	concat(customer.first_name,' ', customer.last_name) as customer_name,
	/*artist.artist_id, */
    artist.name as artist_name,
    /*album.title as album_title,
    track.name as track_name,*/
    sum(invoice_line.unit_price*invoice_line.quantity) as expenditure
from (((((invoice
	join customer on invoice.customer_id = customer.customer_id)
    join invoice_line on invoice.invoice_id = invoice_line.invoice_id)
    join track on track.track_id = invoice_line.track_id)
    join album on album.album_id = track.album_id)
    join artist on artist.artist_id  = album.artist_id)
group by customer.customer_id, artist.artist_id
order by customer_name	
;

/*We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres*/
with my_table as(
select country, genre_name, sum(total) as genre_total, rank() over (partition by country order by sum(total) desc) as rnk
from
	(select distinct 
		genre.name as genre_name, 
		invoice.billing_country as country,
		invoice.total as total
        
	from (((genre
		inner join track on track.genre_id = genre.genre_id)
		inner join invoice_line on invoice_line.track_id = track.track_id)
		inner join invoice on invoice_line.invoice_id = invoice.invoice_id)
	) table_1
group by genre_name, country	
order by country, genre_total desc)

select country, genre_name as most_popular_genre
from my_table 
where rnk =1
;

/*Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount*/
with my_data as (
select 
	concat(customer.first_name, " ", customer.last_name) as Customer, 
    invoice.billing_country as Country, 
    sum(invoice.total) as Expenditure,
	rank() over(partition by invoice.billing_country order by sum(invoice.total) desc) as Rnk
from invoice
	inner join customer on customer.customer_id = invoice.customer_id

group by customer.customer_id
order by country)
select Country, Customer, Expenditure
from my_data 
where Rnk = 1
;

/*Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent*/

select 
	concat(customer.first_name,' ', customer.last_name) as customer_name,
	/*artist.artist_id, */
    artist.name as artist_name,
    /*album.title as album_title,
    track.name as track_name,*/
    sum(invoice_line.unit_price*invoice_line.quantity) as expenditure
from (((((invoice
	join customer on invoice.customer_id = customer.customer_id)
    join invoice_line on invoice.invoice_id = invoice_line.invoice_id)
    join track on track.track_id = invoice_line.track_id)
    join album on album.album_id = track.album_id)
    join artist on artist.artist_id  = album.artist_id)
group by customer.customer_id, artist.artist_id
order by customer_name	
;













