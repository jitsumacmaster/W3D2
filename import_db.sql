

PRAGMA foreign_keys = ON;

CREATE TABLE users (
    user_id INTEGER PRIMARY KEY
    , fname VARCHAR(255) NOT NULL
    , lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
    question_id INTEGER PRIMARY KEY
    , title VARCHAR(255) NOT NULL
    , body VARCHAR(255) NOT NULL
    , user_id INTEGER NOT NULL

    , FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE question_follows (
    question_follow_id INTEGER PRIMARY KEY
    , question_id INTEGER NOT NULL
    , user_id INTEGER NOT NULL

    , FOREIGN KEY (user_id) REFERENCES users(user_id)
    , FOREIGN KEY (question_id) REFERENCES questions(question_id)
);

CREATE TABLE replies (
    reply_id INTEGER PRIMARY KEY
    , question_id INTEGER NOT NULL
    , user_id INTEGER NOT NULL
    , body VARCHAR(255) NOT NULL
    , parent_reply_id INTEGER
    
    , FOREIGN KEY (user_id) REFERENCES users(user_id)
    , FOREIGN KEY (question_id) REFERENCES questions(question_id)
);

CREATE TABLE question_likes (
    question_like_id INTEGER PRIMARY KEY
    , question_id INTEGER NOT NULL
    , user_id INTEGER NOT NULL
    -- , FOREIGN KEY (user_id) REFERENCES users(user_id)
    -- , FOREIGN KEY (question_id) REFERENCES questions(question_id)
);


INSERT INTO
  users (fname, lname)
VALUES
  ('Jitsu', 'MacMaster')
  , ('Eric', 'Leong')
  , ('App', 'Academy');


INSERT INTO
  questions (title, body, user_id)
SELECT
  'Eric Time'
  , 'What time is it?'
  , users.user_id 
FROM users
WHERE
  users.fname = 'Eric';

INSERT INTO
  questions (title, body, user_id)
SELECT
  'HMU'
  , 'Yo. I got a ton of tomatoes and lettuce. Holla atcha boi.'
  , users.user_id 
FROM users
WHERE
  users.fname = 'Jitsu';

INSERT INTO
  questions (title, body, user_id)
SELECT
  'App Academy'
  , 'Holla atcha boi?'
  , users.user_id 
FROM users
WHERE
  users.fname = 'App';

INSERT INTO
  question_likes (question_id, user_id)
VALUES
  (1, 1)
  , (2, 2)
  , (1, 2);

INSERT INTO
  question_likes (question_id, user_id)
VALUES
  (1, 1)
  , (2, 2)
  , (1, 2);


