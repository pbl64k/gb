CREATE DATABASE gb;

USE gb;

CREATE TABLE users (
        id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        login VARCHAR(255) DEFAULT '' NOT NULL,
        password VARCHAR(255) DEFAULT '' NOT NULL,
        realname VARCHAR(255) DEFAULT '' NOT NULL,
        email VARCHAR(255) DEFAULT '' NOT NULL,
        url VARCHAR(255) DEFAULT '' NOT NULL,
        KEY lookup (login, password, id),
        KEY realname (realname)
        );

INSERT INTO users (id, login, password, realname, email, url) VALUES (1, 'admin', 'default-password', 'Administrator', 'root@localhost.localdomain', '');

CREATE TABLE messages (
        id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        userid INT NOT NULL,
        posted DATETIME NOT NULL,
        subject TEXT,
        message TEXT,
        KEY userid (userid),
        KEY posted (posted)
        );

