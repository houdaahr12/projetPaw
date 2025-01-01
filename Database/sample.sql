INSERT INTO
    users (
        name,
        surname,
        email,
        password
    )
VALUES (
        'Alice',
        'Johnson',
        'alice.johnson@example.com',
        'passwordAlice123'
    ),
    

INSERT INTO
    tasks (
        task_name,
        category,
        due_date,
        due_time,
        status,
        priority,
        user_id
    )
VALUES (
        'Finish homework',
        'etude',
        '2024-12-20',
        '14:00:00',
        'pas commence',
        'important',
        1
    ),
    (
        'Work on project',
        'travail',
        '2024-12-21',
        '09:00:00',
        'en cours',
        'moins important',
        1
    ),
    (
        'Clean the house',
        'maison',
        '2024-12-22',
        '16:30:00',
        'pas commence',
        'urgent',
        2
    ),
    