select *
from messages, users
where users.id=messages.userid
order by messages.posted desc
limit ?,?
