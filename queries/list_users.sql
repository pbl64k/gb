select distinct users.*
from users,messages
where users.id=messages.userid
order by users.realname asc
