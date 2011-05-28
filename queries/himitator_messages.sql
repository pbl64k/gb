select subject,message
from messages, users
where users.id=messages.userid
and users.id=?
order by messages.posted desc
