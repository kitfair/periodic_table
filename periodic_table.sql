DELETE FROM properties WHERE atomic_number = 1000;
DELETE FROM elements WHERE atomic_number = 1000;

ALTER TABLE properties RENAME COLUMN weight TO atomic_mass;
ALTER TABLE properties RENAME COLUMN melting_point TO melting_point_celsius;
ALTER TABLE properties RENAME COLUMN boiling_point TO boiling_point_celsius;

ALTER TABLE properties ALTER COLUMN melting_point_celsius SET NOT NULL;
ALTER TABLE properties ALTER COLUMN boiling_point_celsius SET NOT NULL;

ALTER TABLE elements ALTER COLUMN symbol SET NOT NULL;
ALTER TABLE elements ALTER COLUMN name SET NOT NULL;
ALTER TABLE elements ADD CONSTRAINT unique_symbol UNIQUE (symbol);
ALTER TABLE elements ADD CONSTRAINT unique_name UNIQUE (name);

ALTER TABLE properties
  ADD CONSTRAINT fk_atomic_number
  FOREIGN KEY (atomic_number) REFERENCES elements(atomic_number);

CREATE TABLE types (
  type_id INT PRIMARY KEY,
  type VARCHAR NOT NULL
);

INSERT INTO types (type_id, type)
SELECT ROW_NUMBER() OVER (ORDER BY type), type
FROM (SELECT DISTINCT type FROM properties) AS distinct_types;

ALTER TABLE properties ADD COLUMN type_id INT;

UPDATE properties p
SET type_id = t.type_id
FROM types t
WHERE p.type = t.type;

ALTER TABLE properties ALTER COLUMN type_id SET NOT NULL;

ALTER TABLE properties
  ADD CONSTRAINT fk_type_id
  FOREIGN KEY (type_id) REFERENCES types(type_id);

ALTER TABLE properties DROP COLUMN type;

UPDATE elements
SET symbol = INITCAP(symbol);

ALTER TABLE properties ALTER COLUMN atomic_mass TYPE FLOAT;
ALTER TABLE properties ALTER COLUMN atomic_mass TYPE DECIMAL USING atomic_mass::DECIMAL;

INSERT INTO elements (atomic_number, symbol, name)
VALUES (9, 'F', 'Fluorine');

INSERT INTO properties (atomic_number, melting_point_celsius, boiling_point_celsius, atomic_mass, type_id)
VALUES (9, -220, -188.1, 18.998,
  (SELECT type_id FROM types WHERE type = 'nonmetal'));

INSERT INTO elements (atomic_number, symbol, name)
VALUES (10, 'Ne', 'Neon');

INSERT INTO properties (atomic_number, melting_point_celsius, boiling_point_celsius, atomic_mass, type_id)
VALUES (10, -248.6, -246.1, 20.18,
  (SELECT type_id FROM types WHERE type = 'nonmetal'));