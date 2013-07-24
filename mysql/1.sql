
-- http://www.siteduzero.com/informatique/tutoriels/administrez-vos-bases-de-donnees-avec-mysql/creation-de-tables

CREATE TABLE Animal (
    id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    espece VARCHAR(40) NOT NULL,
    sexe CHAR(1),
    date_naissance DATETIME NOT NULL,
    nom VARCHAR(30),
    commentaires TEXT,
    PRIMARY KEY (id)
)
ENGINE=INNODB;

SHOW TABLES;      -- liste les tables de la base de données
 
DESCRIBE Animal;  -- liste les colonnes de la table avec leurs caractéristiques

-- http://www.siteduzero.com/informatique/tutoriels/administrez-vos-bases-de-donnees-avec-mysql/insertion-de-donnees

INSERT INTO Animal VALUES (1, 'chien', 'M', '2010-04-05 13:43:00', 'Rox', 'Mordille beaucoup');
INSERT INTO Animal VALUES (2, 'chat', NULL, '2010-03-24 02:23:00', 'Roucky', NULL);
INSERT INTO Animal VALUES (NULL , 'chat', 'F', '2010-09-13 15:02:00', 'Schtroumpfette', NULL);

INSERT INTO Animal (espece, sexe, date_naissance) VALUES ('tortue', 'F', '2009-08-03 05:12:00');
INSERT INTO Animal (nom, commentaires, date_naissance, espece) VALUES ('Choupi', 'Né sans oreille gauche', '2010-10-03 16:44:00', 'chat');
INSERT INTO Animal (espece, date_naissance, commentaires, nom, sexe) VALUES ('tortue', '2009-06-13 08:17:00', 'Carapace bizarre', 'Bobosse', 'F');

INSERT INTO Animal (espece, sexe, date_naissance, nom)
VALUES ('chien', 'F', '2008-12-06 05:18:00', 'Caroline'),
        ('chat', 'M', '2008-09-11 15:38:00', 'Bagherra'),
        ('tortue', NULL, '2010-08-23 05:18:00', NULL);

SELECT * FROM Animal;

-- http://www.siteduzero.com/informatique/tutoriels/administrez-vos-bases-de-donnees-avec-mysql/remplissage-de-la-base

SOURCE 2.sql;

LOAD DATA LOCAL INFILE '3.csv'
INTO TABLE Animal
FIELDS TERMINATED BY ';' ENCLOSED BY '"'
LINES TERMINATED BY '\n' -- ou '\r\n'
(espece, sexe, date_naissance, nom, commentaires);

