DROP TABLE IF EXISTS toys;
CREATE TABLE toys (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  dog_id INTEGER,

  FOREIGN KEY(dog_id) REFERENCES dog(id)
);

DROP TABLE IF EXISTS dogs;
CREATE TABLE dogs (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES human(id)
);

DROP TABLE IF EXISTS humans;
CREATE TABLE humans (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

INSERT INTO
  humans (id, fname, lname)
VALUES
  (1, "Conrad", "Makow"),
  (2, "Joe", "Schmo"),
  (3, "Jeff", "Smith"),
  (4, "Steph", "Curry");

INSERT INTO
  dogs (id, name, owner_id)
VALUES
  (1, "Bailey", 1),
  (2, "Max", 2),
  (3, "Charlie", 2),
  (4, "Bella", 3),
  (5, "Buddy", 3),
  (6, "Lucy", 3),
  (7, "Molly", 4),
  (8, "Stray", NULL);

INSERT INTO
  toys (id, name, dog_id)
VALUES
  (1, "Grimy Bone", 1),
  (2, "Delicious Bone", 1),
  (3, "Bacon Treat", 2),
  (4, "Squeeze Ball", 3),
  (5, "Teddy Bear", 4),
  (6, "Chew Toy", 5),
  (7, "Tennis Ball", 5),
  (8, "Duck Bone", 6),
  (9, "Old Rope", 6),
  (10, "Torn Stuffed Duck", 7),
  (11, "Teddy Bear with Sunglasses", 8);
