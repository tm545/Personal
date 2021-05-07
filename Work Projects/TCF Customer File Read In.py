#Only need to change this portion for read ins
input_txt =  r'V:\TCF\TCF Customer files\Deluxe152_Results\DeluxeResults_152.csv'
product_map = r'V:\TCF\TCF Customer files\Deluxe152_Results\TCF Product Map.txt'
FMCGID_date = "TCF0121" #shouldbe TCFMMYY
input_CLN_text = r'V:\TCF\TCF Customer files\Deluxe152_Results_2\CLN_011221.csv'
CLN_pmap = r'V:\TCF\TCF Customer files\Deluxe152_Results\TCF CLN Product Map.txt'
CLNFMCGID_date = 'TCFCLN0121' #Should be TCFCLN MMYY

#run "pip install pandas" in powershell and any other names below before running otherwise you'll get errors
import pandas as pd
import numpy as np
import datetime
import time
print("Starting TCF Read in")
class StringConverter(dict):
    def __contains__(self, item):
        return True

    def __getitem__(self, item):
        return str

    def get(self, default=None):
        return str

start_time = time.time()
dataset = pd.read_csv(input_txt, sep = '|', header = 0, converters = StringConverter())

print("Parsed the raw TCF File in %s seconds" % round(time.time() - start_time))
def product_mapping(product_map_path, DataFrame, column):
    dataframe_product = pd.read_csv(product_map_path, sep = '\t',  header = 0, converters = StringConverter())
    array_product = dataframe_product.values
    product_dict = {}
    for row in array_product:
        product_dict[row[0]] =row[1]
    vals = DataFrame[column].values
    ReportPC = []
    for item in vals:
        ReportPC.append(product_dict.get(item, np.nan))

    DataFrame['ReportProductCategory'] = ReportPC
    return DataFrame

Acct_file = product_mapping(product_map, dataset, 'acct_typ')
Acct_file['BusinessFlag'] = np.where(Acct_file['ReportProductCategory'].str.find('Business')>0,1,0)
Acct_file['CheckingFlag'] = np.where(Acct_file['ReportProductCategory'].str.find('Checking')>0,1,0)

#phone cleanup getting rid of phone field with only 0
Acct_file['Phone'] = np.where(Acct_file['Phone'].str.len()>1,Acct_file['Phone'],"")

#making FMCGID
index = range(len(Acct_file['Bank']))
str_index = []
for n in index:
    a = str(n+1)
    str_index.append(FMCGID_date + (a.zfill(9)))
Acct_file['FMCGID'] = str_index

#Name Parsing
Acct_file['fname1'] = np.where(Acct_file['cust_type_cd'] == 'O','', Acct_file['first_nm'])
Acct_file['lname1'] = np.where(Acct_file['cust_type_cd'] == 'O',Acct_file['full_nm'], Acct_file['last_nm'])

#making full file for BI if needed
#full_output_txt = input_txt[0:input_txt.rfind("\\")]+ r'\Full file.txt'
#Acct_file.to_csv(full_output_txt, sep = '\t', index = False)



#Adding useful columns
Acct_file['Address1_CASS'] =''
Acct_file['Address2_CASS'] =''
Acct_file['City_CASS'] =''
Acct_file['State_CASS'] =''
Acct_file['Zip5_CASS'] =''
Acct_file['Zip4_CASS'] =''
Acct_file['Hardmatch'] =''
Acct_file['Matchtype'] =''
Acct_file['Matchcode'] =''
Acct_file['MailfileID'] =''
Acct_file['SweeplinkID'] =''
Acct_file['PreviousMatchClosed'] =''
Acct_file['PreviousMatchID'] =''
Acct_file['Remove'] =''


#datecut file
Acct_file['Open_datetime'] = pd.to_datetime(Acct_file['Open_date'])
start_date = max(Acct_file['Open_datetime']) - datetime.timedelta(days = 180)
end_date =  max(Acct_file['Open_datetime'])
datecut = (Acct_file['Open_datetime'] > start_date) & (Acct_file['Open_datetime']<= end_date)
Acct_file.drop(columns = ['Open_datetime'])

#date clean up not needed in python but needed for access to recognize date
def clean_dates(column):
    column = column.astype(str)
    column = column.str[5:7] + '/' + column.str[8:10] + '/' + column.str[0:4]

    return column
Acct_file['Open_date'] = clean_dates(Acct_file['Open_date'])
Acct_file['birth_dt'] = clean_dates(Acct_file['birth_dt'])
Acct_file['birth_dt'].replace('//','')

Acct_file_datecut = Acct_file.loc[datecut]

print("Finished processing the TCF File in %s seconds" % round(time.time() - start_time))

#Checking for unmapped products
if(Acct_file['ReportProductCategory'].isnull().values.any() == True):
    missing_products = Acct_file['ReportProductCategory'].isnull()
    find_missing = Acct_file.loc[missing_products, ('acct_typ', 'acct_typ_desc')]
    find_missing['good_column'] = find_missing['acct_typ'] + '\t' + find_missing['acct_typ_desc']
    print("You have unmapped products, update your product map to contain the account types below.")
    for item in find_missing.good_column.unique():
        print(item)
Acct_file['ReportProductCategory'].fillna('', inplace=True)

output_txt = input_txt[0:input_txt.rfind("\\")]+ r'\Customer file.txt'
Acct_file_datecut.to_csv(output_txt, sep = '\t', index = False)
print("Wrote the TCF Customer file here: " + output_txt)

CLN_df = pd.read_csv(input_CLN_text, sep = '|', header=0, converters = StringConverter())
print("Parsed in the raw CLN file in %s seconds" % round(time.time() - start_time))


#making FMCGID
index = range(len(CLN_df['bank_nbr']))
str_index = []
for n in index:
    a = str(n+1)
    str_index.append(CLNFMCGID_date + (a.zfill(6)))
CLN_df['FMCGID'] = str_index

#extracting zip5 and zip4
CLN_df['zip5'] = CLN_df['mail_zip_cd'].astype(str).str[0:5]
CLN_df['zip4'] = np.where(CLN_df['mail_zip_cd'].astype(str).str.len()>9,CLN_df['mail_zip_cd'].astype(str).str[6:10],'')

CLN_file = product_mapping(CLN_pmap, CLN_df, 'prod_cd')
CLN_file['BusinessFlag'] = np.where((CLN_file['ReportProductCategory'].str.find('Business')) + (CLN_file['ReportProductCategory'].str.find('CRE')) >0,1,0)
CLN_file['CheckingFlag'] = 0

#phone cleanup getting rid of phone field with only 0
CLN_file['phone'] = np.where(CLN_file['phone'].str.len()>1,CLN_file['phone'],"")

#date cutting loans files
CLN_file['Open_datetime'] = pd.to_datetime(CLN_file['orig_proc_dt'])
start_date = max(CLN_file['Open_datetime']) - datetime.timedelta(days = 180)
end_date =  max(CLN_file['Open_datetime'])
datecut = (CLN_file['Open_datetime'] > start_date) & (CLN_file['Open_datetime']<= end_date)
CLN_file.drop(columns = ['Open_datetime'])

CLN_file['Open_date'] = clean_dates(CLN_file['orig_proc_dt'])

CLN_file_datecut = CLN_file.loc[datecut]

print("Finished processing the CLN File in %s seconds" % round(time.time() - start_time))


#Checking for unmapped products
if(CLN_file['ReportProductCategory'].isnull().values.any() == True):
    missing_products = CLN_file['ReportProductCategory'].isnull()
    find_missing = CLN_file.loc[missing_products, ('prod_cd', 'prod_cd_desc')]
    find_missing['good_column'] = find_missing['prod_cd'] + '\t' + find_missing['prod_cd_desc']
    print("You have unmapped products, update your CLN product map to contain the account types below.")
    for item in find_missing.good_column.unique():
        print(item)
CLN_file['ReportProductCategory'].fillna('', inplace=True)

output_CLN_text = input_txt[0:input_txt.rfind("\\")]+ r'\CLN file.txt'
CLN_file_datecut.to_csv(output_CLN_text, sep = '\t', index = False)
print("Wrote the TCF Loans file here: " + output_CLN_text)

print("All done in %s seconds" % round(time.time() - start_time))
