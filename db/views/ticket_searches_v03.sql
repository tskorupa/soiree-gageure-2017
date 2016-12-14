SELECT
  tickets.id AS ticket_id,
  '' || tickets.number || '' AS term
FROM
  tickets

UNION

SELECT
  tickets.id AS ticket_id,
  sellers.full_name AS term
FROM
  tickets
  INNER JOIN sellers ON tickets.seller_id = sellers.id

UNION

SELECT
  tickets.id AS ticket_id,
  guests.full_name AS term
FROM
  tickets
  INNER JOIN guests ON tickets.guest_id = guests.id

UNION

SELECT
  tickets.id AS ticket_id,
  sponsors.full_name AS term
FROM
  tickets
  INNER JOIN sponsors ON tickets.sponsor_id = sponsors.id
