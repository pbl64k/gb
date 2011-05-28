select users.id
from users
where users.login=? and users.password=? and users.id=0
limit 0,1
