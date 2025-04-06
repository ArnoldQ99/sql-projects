-- You vaguely remember that the crime was a murder that occurred sometime on Jan.15, 2018 and that it took place in SQL City
SELECT * FROM crime_scene_report
WHERE date =20180115
AND type = 'murder'
AND city = 'SQL City';

-- Result: 	Security footage shows that there were 2 witnesses. The first witness lives at the last house on "Northwestern Dr". The second witness, named Annabel, lives somewhere on "Franklin Ave"
SELECT * FROM person
WHERE address_street_name = 'Northwestern Dr'
OR (address_street_name = 'Franklin Ave' AND name LIKE '%Annabel%')
ORDER BY address_street_name, address_number DESC
LIMIT 2;

-- Result: 2 Witnesses, next is to retrieve their interviews.
WITH witnesses AS (
SELECT * FROM person
WHERE address_street_name = 'Northwestern Dr'
OR (address_street_name = 'Franklin Ave' AND name LIKE '%Annabel%')
ORDER BY address_street_name, address_number DESC
LIMIT 2
  )
  SELECT * FROM interview
  INNER JOIN witnesses
  ON interview.person_id = witnesses.id

--Results: 
--Transcirpt 1: I saw the murder happen, and I recognized the killer from my gym when I was working out last week on January the 9th.
--Transcirpt 2: I heard a gunshot and then saw a man run out. He had a "Get Fit Now Gym" bag. The membership number on the bag started with "48Z". Only gold members have those bags. The man got into a car with a plate that included "H42W".
WITH suspect AS (
SELECT * FROM get_fit_now_member AS m
INNER JOIN get_fit_now_check_in AS c
ON m.id = c.membership_id
WHERE check_in_date = 20180109
AND (membership_status = 'gold' AND membership_id LIKE '48Z%')
  )
  SELECT d.*, p.name FROM drivers_license AS d
  INNER JOIN person AS p
  ON p.license_id = d.id
  INNER JOIN suspect AS s
  ON s.person_id = p.id

--Result: Congrats, you found the murderer! But wait, there's more... If you think you're up for a challenge, try querying the interview transcript of the murderer to find the real villain behind this crime.
SELECT * FROM interview AS i
INNER JOIN person AS p
ON i.person_id = p.id
WHERE name = 'Jeremy Bowers'

-- Result:
-- I was hired by a woman with a lot of money. I don't know her name but I know she's around 5'5" (65") or 5'7" (67").
-- She has red hair and she drives a Tesla Model S.
-- I know that she attended the SQL Symphony Concert 3 times in December 2017.
SELECT p.name FROm drivers_license AS d
INNER JOIN person as p
ON p.license_id = d.id
INNER JOIN facebook_event_checkin as f
ON f.person_id = p.id
WHERE (d.height BETWEEN 54 AND 58 OR d.height BETWEEN 64 AND 68)
AND d.hair_color = 'red'
AND d.car_make = 'Tesla'
AND d.car_model = 'Model S'
AND f.event_name = 'SQL Symphony Concert'
AND f.date LIKE '201712%'

-- Result: Miranda Priestly
-- Result: Congrats, you found the brains behind the murder! Everyone in SQL City hails you as the greatest SQL detective of all time. Time to break out the champagne!
