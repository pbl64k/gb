select *
from messages, users
where users.id=messages.userid
and users.id=6
and messages.subject rlike '^[0-9]{1,4}\. .*'
order by messages.posted asc
