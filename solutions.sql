

-- ## A. Boshlang'ich daraja (SELECT, WHERE, GROUP BY)
SELECT * FROM customers;
SELECT * FROM accounts;
SELECT * FROM branches;
SELECT * FROM transactions;
SELECT * FROM loans;
SELECT * FROM loan_payments;

-- 1. Har bir viloyat bo'yicha nechta mijoz va nechta filial bor?

SELECT
	b.region AS viloyat,
	COUNT(DISTINCT c.customer_id) AS mijoz_soni,
	COUNT(DISTINCT b.branch_id) AS filial_soni
FROM customers c
JOIN branches b ON c.branch_id = b.branch_id
GROUP BY 1
ORDER BY 2 DESC;



-- 2. Mijozlar segmentlari (Standart, Premium, VIP) bo'yicha o'rtacha oylik daromad qancha?
SELECT * FROM customers;

SELECT
	segment,
	ROUND(AVG(monthly_income_uzs), 1) AS ortacha_oylik
FROM customers
GROUP BY segment;




-- 3. Qaysi kasb egalari eng ko'p mijoz bo'lgan va ularning o'rtacha daromadi qancha?
SELECT 
	occupation AS kasb,
	COUNT(customer_id) AS mijoz_soni,
	ROUND(AVG(monthly_income_uzs), 0) AS ortacha_daromadi
FROM customers
GROUP BY occupation
ORDER BY mijoz_soni DESC;




-- 4. Hisob turlari (Joriy, Jamg'arma, Karta) bo'yicha nechta hisob va o'rtacha balans qancha?
SELECT
	account_type AS hisob_turi,
	COUNT(*) AS hisob_soni,
	ROUND(AVG(balance), 2) AS ortacha_balans 
FROM accounts
GROUP BY hisob_turi
ORDER BY hisob_soni DESC;

-- 5. Tranzaksiya turlari bo'yicha muvaffaqiyatli, rad etilgan va bekor qilingan operatsiyalar ulushi qancha?
SELECT
    transaction_type,
    status,
    COUNT(*) AS tranzaksiyalar_soni,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY transaction_type), 2) AS soni_boyicha_ulush_foiz,
    ROUND(100.0 * SUM(amount) / SUM(SUM(amount)) OVER (PARTITION BY transaction_type), 2) AS summa_boyicha_ulush_foiz
FROM transactions
GROUP BY transaction_type, status
ORDER BY transaction_type, status;


-- 6. Har bir yil va oy bo'yicha tranzaksiyalar soni va umumiy summasi (UZS) qanday o'zgargan?
SELECT 
	EXTRACT(YEAR FROM transaction_date) AS year,
	EXTRACT(MONTH FROM transaction_date) AS month,
	COUNT(transaction_id) AS tranzaksiyalar_soni,
	SUM(amount) AS balans
FROM transactions
WHERE currency = 'UZS'
GROUP BY 1, 2;

-- 7. Eng ko'p ishlatiladigan kanal qaysi va kanallar bo'yicha o'rtacha chek qancha?
SELECT 
    channel,
    COUNT(*) AS tranzaksiyalar_soni,
    ROUND(AVG(amount), 2) AS ortacha_chek_uzs
FROM transactions
WHERE currency = 'UZS' AND status = 'Muvaffaqiyatli'
GROUP BY channel
ORDER BY tranzaksiyalar_soni DESC;







-- ## B. O'rta daraja (JOIN, HAVING, CASE)

SELECT * FROM customers;
SELECT * FROM accounts;
SELECT * FROM branches;
SELECT * FROM transactions;
SELECT * FROM loans;
SELECT * FROM loan_payments;

-- 8. Har bir filial bo'yicha mijozlar soni, hisoblar soni va jami balans qancha?
SELECT
	b.branch_name AS filial,
	COUNT(DISTINCT c.customer_id) AS mijoz_soni,
	COUNT(DISTINCT a.account_id) AS hisob_soni,
	SUM(balance) AS jami_balans
FROM customers c
JOIN accounts a ON a.customer_id = c.customer_id
JOIN branches b ON b.branch_id = c.branch_id
GROUP BY 1;



-- 9. Eng ko'p xarid qilgan 10 ta mijoz kim (UZS, faqat muvaffaqiyatli xaridlar)?
SELECT
	c.customer_id,
	c.first_name || ' ' || c.last_name AS ismi,
	SUM(t.amount) AS xarid_summasi
FROM customers c
JOIN accounts a ON a.customer_id = c.customer_id
JOIN transactions t ON t.account_id = a.account_id
WHERE t.status = 'Muvaffaqiyatli' AND t.transaction_type = 'Xarid' AND t.currency = 'UZS'
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

-- 10. Kategoriyalar (Oziq-ovqat, Elektronika, Transport va h.k.) bo'yicha xarajat ulushi foizda qancha?
SELECT 
	category,
	ROUND(
		(SUM(amount) * 100.0 / SUM(SUM(amount)) OVER()), 2
	) AS xarajat_ulushi_foizda
FROM transactions
GROUP BY category
ORDER BY 2 DESC;


-- 11. Yosh guruhlari (18-25, 26-35, 36-50, 50+) bo'yicha o'rtacha xarajat va kredit olish ulushi qanday?
SELECT * FROM transactions;

WITH avg_xarajat AS(
	SELECT
		a.customer_id,
		SUM(t.amount) AS jami_xarajat
	FROM transactions t
	JOIN accounts a ON t.account_id = a.account_id
	WHERE t.status = 'Muvaffaqiyatli' AND t.currency = 'UZS' AND t.transaction_type != 'Kirim'
	GROUP BY a.customer_id
),
kredit AS(
	SELECT 
		DISTINCT customer_id, 
		1 AS kredit_olgan
	FROM loans
)
SELECT
	CASE
		WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, c.birth_date)) BETWEEN 18 AND 25 THEN '18-25'
		WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, c.birth_date)) BETWEEN 26 AND 35 THEN '26-35'
		WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, c.birth_date)) BETWEEN 36 AND 50 THEN '36-50'
		ELSE '50+'
	END AS yosh_guruh,
	COUNT(*) AS mijozlar,
	ROUND(AVG(COALESCE(ax.jami_xarajat, 0)), 0) AS ortacha_xarajat,
	ROUND(100.0 * COUNT(k.kredit_olgan) / COUNT(*), 1) AS ulush
FROM customers c
LEFT JOIN avg_xarajat ax ON c.customer_id = ax.customer_id
LEFT JOIN kredit k ON c.customer_id = k.customer_id
GROUP BY 1
ORDER BY 1;


-- 12. Hech qachon tranzaksiya qilmagan yoki oxirgi 90 kunda faol bo'lmagan mijozlar kimlar (LEFT JOIN)?
SELECT * FROM customers;
SELECT * FROM transactions;

WITH max_t_date AS (
	SELECT 
		a.customer_id,
		MAX(transaction_date) AS max_transaction_date
	FROM accounts a
	JOIN transactions t ON a.account_id = t.account_id
	GROUP BY a.customer_id
)
SELECT
	c.customer_id,
	c.first_name || ' ' || c.last_name AS full_name,
	m.max_transaction_date
FROM customers c
LEFT JOIN max_t_date m ON m.customer_id = c.customer_id
WHERE m.max_transaction_date < (SELECT MAX(transaction_date) FROM transactions) - INTERVAL '90 days' OR m.max_transaction_date IS NULL

-- 13. Daromadidan ko'p xarajat qiladigan mijozlar kimlar (oylik chiqim > oylik daromad)?

WITH oylik AS(
	SELECT 
		a.customer_id,
		TO_CHAR(t.transaction_date, 'YYYY-MM') AS sana,
		SUM(CASE WHEN t.transaction_type = 'Kirim' THEN t.amount ELSE 0 END) AS kirim,
		SUM(CASE WHEN t.transaction_type != 'Kirim' THEN t.amount ELSE 0 END) AS chiqim
	FROM accounts a 
	JOIN transactions t ON a.account_id = t.account_id
	WHERE t.currency = 'UZS' AND t.status = 'Muvaffaqiyatli'
	GROUP BY a.customer_id, 2
)
SELECT
	c.customer_id,
	c.first_name || ' ' || c.last_name AS full_name,
	COUNT(*) AS oylar_soni
FROM customers c
JOIN oylik o ON o.customer_id = c.customer_id
WHERE o.chiqim > o.kirim
GROUP BY 1, 2;



-- 14. Bir nechta hisobi bor, lekin ulardan biri yopilgan mijozlarni toping.

SELECT
	a.customer_id,
	CONCAT_WS(' ', c.first_name, c.last_name) AS name,
	COUNT(*) AS soni 
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
GROUP BY a.customer_id, 2
HAVING COUNT(*) > 1 AND COUNT(CASE WHEN a.status = 'Yopilgan' THEN 1 END) >= 1
ORDER BY 1;


-- 15. Kredit turlari bo'yicha berilgan summa, o'rtacha foiz stavkasi va muddati o'tgan kreditlar ulushi qancha?

SELECT * FROM loans;

SELECT
	loan_type,
	SUM(loan_amount_uzs) AS jami_summa,
	ROUND(AVG(interest_rate), 2) AS ortacha_foiz_stavkasi,
	COUNT(*) AS shartnomalar_soni,
	ROUND(
		100.0 * COUNT(CASE WHEN status = 'Muddati o''tgan' THEN 1 END) / COUNT(*),
		2
	) AS muddati_otgan_kreditlar_ulushi
FROM loans
GROUP BY loan_type;


