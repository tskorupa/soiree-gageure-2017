SELECT
  tickets.id AS ticket_id,
  '' || tickets.number || '' AS term
FROM
  tickets

UNION

SELECT
  tickets.id AS ticket_id,
  tickets.seller_name AS term
FROM
  tickets

UNION

SELECT
  tickets.id AS ticket_id,
  tickets.guest_name AS term
FROM
  tickets

UNION

SELECT
  tickets.id AS ticket_id,
  tickets.sponsor_name AS term
FROM
  tickets
