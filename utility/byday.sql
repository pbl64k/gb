select count(*),date_format(posted,'%Y-%m-%d') postdate from messages group by postdate order by postdate;
exit
