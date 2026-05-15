import argparse, pandas as pd, logging
from pathlib import Path

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s',
    handlers=[logging.FileHandler('analyze.log'), logging.StreamHandler()]
)

def analyze(filepath, region=None, year=None):
    logging.info(f'Loading {filepath}')
    df = pd.read_csv(filepath, encoding='latin1')
    df['Order Date'] = pd.to_datetime(df['Order Date'])
    
    if region:
        df = df[df['Region'] == region]
        logging.info(f'Filtered to region: {region}')
    if year:
        df = df[df['Order Date'].dt.year == int(year)]
        logging.info(f'Filtered to year: {year}')
    
    summary = df.groupby('Category').agg(
        total_sales   = ('Sales', 'sum'),
        total_profit  = ('Profit','sum'),
        num_orders    = ('Order ID','nunique')
    ).round(2)
    
    out = f'summary_{region or "all"}_{year or "all"}.csv'
    summary.to_csv(out)
    logging.info(f'Saved to {out}')
    return summary

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Superstore Sales Analysis')
    parser.add_argument('filepath',  help='Path to CSV file')
    parser.add_argument('--region',  help='Filter: East/West/Central/South')
    parser.add_argument('--year',    help='Filter: 2014-2017')
    args = parser.parse_args()
    result = analyze(args.filepath, args.region, args.year)
    print(result.to_string())
