select users.id
from users
where users.login=? and users.password=?
limit 0,1
