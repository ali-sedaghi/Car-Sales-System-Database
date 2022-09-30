-- 1
INSERT INTO SalePlan VALUES (
    1,
    '2020-01-01 11:00:00',
    '2020-01-07 23:59:59',
    'presale',
    'New Year Sale'
);

-- 2
INSERT INTO SalePlan VALUES (
    2,
    '2020-06-01 11:00:00',
    '2020-06-01 12:00:00',
    'normal',
    'Ramadan Mobarak'
);

-- 3
INSERT INTO SalePlan VALUES (
    3,
    '2020-10-01 11:00:00',
    '2020-10-07 23:59:59',
    'normal',
    '22 Bahman'
);

-- 4
INSERT INTO SalePlan VALUES (
    4,
    '2021-03-01 11:00:00',
    '2021-03-07 23:59:59',
    'presale',
    'Summer Sale'
);

-- ERROR -- 5
INSERT INTO SalePlan VALUES (
    5,
    '2021-10-07 11:00:00',
    '2021-10-01 23:59:59',
    'presale',
    'Winter Sale'
);