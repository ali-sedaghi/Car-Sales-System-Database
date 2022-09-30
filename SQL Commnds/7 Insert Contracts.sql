-- 1
INSERT INTO Contracts VALUES (
    1,
    1,
    4,
    '2020-01-04 16:17:23',
    'Razi'
);

-- 2
INSERT INTO Contracts VALUES (
    2,
    2,
    4,
    '2020-01-02 11:23:17',
    'Iran'
);

-- 3
INSERT INTO Contracts VALUES (
    3,
    3,
    6,
    '2020-06-01 11:03:09',
    DEFAULT
);

-- 4
INSERT INTO Contracts VALUES (
    4,
    4,
    5,
    '2020-06-01 11:05:57',
    'Mellat'
);

-- 5
INSERT INTO Contracts VALUES (
    5,
    5,
    6,
    '2020-06-01 11:04:33',
    'Iran'
);

-- 6
INSERT INTO Contracts VALUES (
    6,
    6,
    8,
    '2020-10-05 07:41:16',
    'Razi'
);

-- 7
INSERT INTO Contracts VALUES (
    7,
    7,
    8,
    '2020-10-02 09:21:16',
    'Iran'
);

-- 8
INSERT INTO Contracts VALUES (
    8,
    9,
    14,
    '2021-03-06 18:38:36',
    'Iran'
);

-- 9
INSERT INTO Contracts VALUES (
    9,
    10,
    15,
    '2021-03-04 21:12:51',
    'Mellat'
);

-- ERROR -- 10
INSERT INTO Contracts VALUES (
    10,
    8,
    15,
    '2021-03-08 23:59:59',
    'Mellat'
);

-- ERROR -- 10
INSERT INTO Contracts VALUES (
    10,
    8,
    15,
    '2021-03-01 10:59:59',
    'Mellat'
);

-- Making the run out of cars trigger firing
UPDATE VehicleForSale SET available = 0 WHERE id = 1;

INSERT INTO Contracts VALUES (
    10,
    8,
    1,
    '2020-01-01 12:00:00',
    'Mellat'
);