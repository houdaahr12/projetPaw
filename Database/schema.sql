CREATE DATABASE goalgetter;

USE goalgetter;


CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL ,
    surname VARCHAR(255) NOT NULL ,
    email VARCHAR(255) NOT NULL ,
    password VARCHAR(255) NOT NULL
);


CREATE TABLE tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    task_name VARCHAR(255) NOT NULL,
    category ENUM(
        'etude',
        'travail',
        'maison',
        'personnel',
        'loisirs',
        'autre'
    ) NOT NULL,
    due_date DATE NOT NULL,
    due_time TIME NOT NULL,
    status ENUM(
        'pas commence',
        'en cours',
        'termine'
    ) DEFAULT 'pas commence',
    priority ENUM('moins important', 'impotant', 'urgent'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INT NOT NULL,
    completed_date DATE DEFAULT NULL,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);