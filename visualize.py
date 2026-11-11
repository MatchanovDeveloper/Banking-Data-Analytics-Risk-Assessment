import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Datalarni o'qish
customers = pd.read_csv('data/customers.csv')
loans = pd.read_csv('data/loans.csv')
transactions = pd.read_csv('data/transactions.csv')
accounts = pd.read_csv('data/accounts.csv')

sns.set_theme(style="whitegrid")
fig, axes = plt.subplots(2, 2, figsize=(16, 12))

# 1. Kredit turlari bo'yicha muddati o'tganlar ulushi (%)
loan_stat = loans.groupby('loan_type').agg(
    total=('loan_id', 'count'),
    overdue=('status', lambda s: (s == "Muddati o'tgan").sum())
).reset_index()
loan_stat['overdue_pct'] = (loan_stat['overdue'] / loan_stat['total']) * 100
loan_stat = loan_stat.sort_values(by='overdue_pct', ascending=False)

sns.barplot(data=loan_stat, x='loan_type', y='overdue_pct', ax=axes[0, 0], 
            palette=['#E63946', '#457B9D', '#A8DADC', '#2A9D8F'])
axes[0, 0].set_title("Kredit turlari bo'yicha muddati o'tganlar ulushi (%)", fontsize=13, fontweight='bold')
axes[0, 0].set_ylabel("Muddati o'tganlar ulushi (%)")
for p in axes[0, 0].patches:
    axes[0, 0].annotate(f"{p.get_height():.1f}%", (p.get_x() + p.get_width() / 2., p.get_height()),
                        ha='center', va='bottom', fontsize=11, fontweight='bold', xytext=(0, 4), textcoords='offset points')

# 2. Kanallar bo'yicha tranzaksiyalar soni
tx_uzs = transactions[(transactions['currency'] == 'UZS') & (transactions['status'] == 'Muvaffaqiyatli')]
channel_stat = tx_uzs.groupby('channel')['transaction_id'].count().reset_index().sort_values(by='transaction_id', ascending=False)

sns.barplot(data=channel_stat, x='transaction_id', y='channel', ax=axes[0, 1], palette='Blues_r')
axes[0, 1].set_title("Muvaffaqiyatli tranzaksiyalar soni (Kanal kesimida)", fontsize=13, fontweight='bold')
axes[0, 1].set_xlabel("Tranzaksiyalar soni")

# 3. Oylik aylanma dinamikasi (Mlrd UZS)
tx_uzs_copy = tx_uzs.copy()
tx_uzs_copy['year_month'] = pd.to_datetime(tx_uzs_copy['transaction_date']).dt.to_period('M').astype(str)
trend = tx_uzs_copy.groupby('year_month')['amount'].sum().reset_index()
trend['amount_bln'] = trend['amount'] / 1e9

sns.lineplot(data=trend, x='year_month', y='amount_bln', ax=axes[1, 0], marker='o', color='#1D3557', linewidth=2.5)
axes[1, 0].set_title("Oylik aylanma dinamikasi (Milliard UZS)", fontsize=13, fontweight='bold')
axes[1, 0].tick_params(axis='x', rotation=45)

# 4. Hisob turlari bo'yicha likvidlik taqsimoti
acc_stat = accounts.groupby('account_type')['balance'].sum().reset_index()
axes[1, 1].pie(acc_stat['balance'], labels=acc_stat['account_type'], autopct='%1.1f%%',
               startangle=140, colors=['#52B788', '#2D6A4F', '#74C69D'], explode=(0.04, 0.04, 0.04))
axes[1, 1].set_title("Jami balansning hisob turlari bo'yicha taqsimoti", fontsize=13, fontweight='bold')

plt.tight_layout()
plt.savefig('docs/dashboard_preview.png', dpi=300)
plt.show()