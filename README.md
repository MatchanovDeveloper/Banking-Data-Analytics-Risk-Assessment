# 🏦 Banking Data Analytics & Risk Assessment (SQL)

Ushbu loyiha bank ma'lumotlar bazasini (2 000 mijoz, 3 159 hisob raqami, 850 ta kredit shartnomasi va 57 000+ tranzaksiya) tahlil qilish, kredit portfelidagi risklarni baholash hamda biznes qarorlar qabul qilish uchun amaliy insightlar ishlab chiqishga qaratilgan.

---

## 📌 Mundarija
1. [Loyiha Arxitekturasi va Datalar](#-loyiha-arxitekturasi-va-datalar)
2. [Asosiy Biznes Insightlar](#-asosiy-biznes-insightlar)
3. [Tahlil Natijalari (Raqamlarda)](#-tahlil-natijalari-raqamlarda)
4. [Texnik SQL Yechimlari](#-texnik-sql-yechimlari)
5. [O'rnatish va Ishga Tushirish](#-ornatish-va-ishga-tushirish)

---

## 🏗 Loyiha Arxitekturasi va Datalar

Loyiha quyidagi asosiy relyatsion jadvallardan tashkil topgan:
- **`customers`**: Mijozlarning demografik ma'lumotlari, yoshi, kasbi, segmenti va oylik daromadi.
- **`branches`**: Bank filiallari va ularning hududiy taqsimoti.
- **`accounts`**: Hisob raqamlari (Joriy, Jamg'arma, Karta), ularning holati va balanslari.
- **`transactions`**: Operatsiyalar tarixi (kanallar, kategoriyalar, valyuta, status).
- **`loans` & `loan_payments`**: Kredit portfeli, foiz stavkalari, to'lov grafigi va muddati o'tgan qarzdorliklar.

---

## 💡 Asosiy Biznes Insightlar

### 1. ⚠️ Ipoteka Kreditlaridagi Yuqori Risk (NPL / Default xatari)
- **Topilma:** Umumiy kredit portfelining 73% qismi (121 mlrd UZS) ipoteka kreditlariga to'g'ri keladi. Biroq ushbu turdagi kreditlarning **20.1% qismi (45 ta shartnoma)** muddati o'tgan holatda.
- **Taqqoslama:** Avtokreditlarda kechikish 6.1%, iste'mol kreditlarida 2.4%, mikroqarzlarda esa 0% ni tashkil etadi.
- **Strategik tavsiya:** Ipoteka anderrayting siyosatini (mijoz daromadiga nisbatan qarz yuki — DTI) qayta ko'rib chiqish va erta ogohlantirish (early collection) tizimini joriy etish lozim.

### 2. 💳 Likvidlik Resurslari: Karta vs Jamg'arma
- **Topilma:** Mijozlar o'z mablag'larini asosan karta hisoblarida saqlamoqda (jami 7.87 mlrd UZS, o'rtacha balans 7.7 mln UZS). Bank uchun eng barqaror resurs hisoblangan jamg'arma (muddatli depozit) hisoblarida esa atigi 4.43 mlrd UZS (o'rtacha balans 4.1 mln UZS) mavjud.
- **Strategik tavsiya:** Bo'sh turgan karta qoldiqlarini muddatli depozitlarga jalb qilish uchun avtomatik jamg'arma (piggy-bank / keshbekni jamg'armaga o'tkazish) funksiyalarini ishga tushirish kerak.

### 3. 📱 Mijozlar Xatti-Harakati va Kanallar Effektivligi
- **Topilma:** Eng ommabop kanal — **Mobil ilova** (19 024 ta muvaffaqiyatli tranzaksiya). Filial orqali o'tadigan operatsiyalar soni kam (1 776 ta), ammo o'rtacha cheki eng yuqori (2.95 mln UZS).
- **Strategik tavsiya:** Kundalik operatsiyalarni to'liq raqamli kanallarga yo'naltirib, filial xodimlarini yuqori marjali mahsulotlar (investitsiyalar, yirik kreditlar, premium xizmatlar) sotuviga yo'naltirish maqsadga muvofiq.

### 4. 🗺 Geografik Konsentratsiya
- Mijozlar bazasining asosiy qismi **Toshkent shahri (572)**, **Andijon (306)** va **Samarqand (302)** filiallariga to'g'ri keladi. Qolgan viloyatlarda esa mijozlar qamrovi nisbatan past.

---

## 📈 Tahlil Natijalari (Raqamlarda)

### Kredit portfeli risk matricasi:
| Kredit turi | Jami summa (UZS) | O'rtacha stavka | Shartnomalar soni | Kechikish ulushi (%) |
| :--- | :--- | :--- | :--- | :--- |
| **Ipoteka** | 121,042,000,000 | 18.85% | 224 | **20.09%** |
| **Avtokredit** | 34,794,000,000 | 23.96% | 213 | **6.10%** |
| **Iste'mol krediti** | 6,697,000,000 | 26.13% | 206 | **2.43%** |
| **Mikroqarz** | 3,339,000,000 | 30.93% | 207 | **0.00%** |

### Kanallar kesimidagi ko'rsatkichlar (UZS):
| Kanal | Tranzaksiyalar soni | O'rtacha chek (UZS) |
| :--- | :--- | :--- |
| **Mobil ilova** | 19,024 | 2,185,704 |
| **Terminal** | 13,227 | 1,801,055 |
| **Internet bank** | 9,282 | 1,643,967 |
| **Bankomat** | 7,589 | 1,669,060 |
| **Filial** | 1,776 | 2,946,457 |

---

## 💻 Texnik SQL Yechimlari

Loyiha doirasida quyidagi murakkab SQL tushunchalari qo'llanildi:
- **CTE (Common Table Expressions):** Mijozlarning jami xarajatlari va kredit statuslarini alohida virtual jadvallarga ajratib tahlil qilish (11, 12, 13-so'rovlar).
- **Window Functions (`OVER (PARTITION BY ...)`):** Har bir tranzaksiya turi va xarajat kategoriyasining umumiy hajmga nisbatan foiz ulushini hisoblash (5, 10-so'rovlar).
- **Dinamik vaqt intervallari:** Oxirgi faoliyat sanasini qat'iy `CURRENT_DATE` emas, bazadagi maksimal tranzaksiya sanasiga bog'lash orqali real nofaol mijozlarni aniqlash (12-so'rov).
- **Agregatsiyalar va filtrlash:** Valyuta farqlarini (`UZS` va `USD`) ajratib to'g'ri o'rtacha chekni hisoblash.

---

## 🚀 O'rnatish va Ishga Tushirish

1. Ushbu repozitoriyani klon qiling:
   ```bash
   git clone [https://github.com/MatchanovDeveloper/banking-sql-analytics.git](https://github.com/MatchanovDeveloper/banking-sql-analytics.git)
   cd banking-sql-analytics
