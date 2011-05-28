select users.realname,(sum(length(message))/count(*)) cnt from messages,users where messages.userid=users.id group by users.id order by cnt desc;
exit
