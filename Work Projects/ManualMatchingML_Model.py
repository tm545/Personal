#!/usr/bin/env python
# coding: utf-8

# In[1]:


# Load libraries
from pandas import read_csv
from pandas import DataFrame
from pandas.plotting import scatter_matrix
from matplotlib import pyplot
from sklearn.model_selection import train_test_split
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import StratifiedKFold
from sklearn.metrics import classification_report
from sklearn.metrics import confusion_matrix
from sklearn.metrics import accuracy_score
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.naive_bayes import GaussianNB
from sklearn.svm import SVC
from sklearn.ensemble import RandomForestClassifier
import pandas as pd
import csv
import time
from collections import Counter 
from fuzzywuzzy import fuzz
import re
import numpy as np
from pathlib import Path
import pickle
from joblib import dump, load


# In[2]:


__non_address_chars_pattern__ = re.compile("[^a-zA-Z0-9\s\&\#]+")

# Dictionaries for word standardization
try:
    __standardization_replacements_path__ = r"Q:\FMCGDirect IP\FMCG Innovation Hub\Python\Repos\addressmatching_1\addressmatching\replacement_lookups\standardization_replacements.txt"  
    # Take replacement_dict_file_path and turn it into a dictionary
    __replacements__ = {line.split(":")[0].strip(): line.split(":")[1].strip() for line in open(__standardization_replacements_path__)}
except FileNotFoundError:
    __standardization_replacements_path__ = r"Q:\FMCGDirect IP\FMCG Innovation Hub\Python\Repos\addressmatching_1\addressmatching\replacement_lookups\standardization_replacements.txt"
    
    # Take replacement_dict_file_path and turn it into a dictionary
    __replacements__ = {line.split(":")[0].strip(): line.split(":")[1].strip() for line in open(__standardization_replacements_path__)}
    
    

class Address:
    
    def __init__(self, input_address):
        
        self.address_split = self.init_address(input_address)
        
        street_char, self.street_number = self.extract_street(self.address_split)
        apartment_char, apartment_num = self.extract_apartment(self.address_split)

        if apartment_char or apartment_num:
            self.apartment = apartment_num + ''.join(sorted(set(street_char + apartment_char)))
        else:
            self.apartment = street_char

        self.street = [item for item in self.address_split if item not in (self.street_number+street_char, apartment_char+apartment_num, self.apartment.replace('#', '')) and '#' not in item]
        holder_string = ''
        for element in self.street:
            holder_string += str(element)
            holder_string += ' '
        self.street = holder_string
            
    @staticmethod
    def init_address(input_address):
        input_address = input_address.lower()
        input_address = __non_address_chars_pattern__.sub('', input_address)
        input_address = ' '.join(__replacements__[item] if item in __replacements__ else item for item in input_address.split())
        input_address = input_address.replace("hwy rte", "rte")
        input_address = input_address.replace("state rte", "rte")
        input_address = input_address.replace("county rte", "rte")
        input_address = input_address.replace("# ", "")
        input_address = input_address.split()
        return input_address
        
    @staticmethod
    def num_and_char(s):
        return s.isalnum() and not s.isalpha() and not s.isnumeric()
    
    @staticmethod
    def split_alphanum(s):
        alpha_part = ''.join(char for char in s if char.isalpha())
        num_part   = s.replace(alpha_part, '')
        return alpha_part, num_part
    
    @staticmethod
    def extract_street(split_address):
        try:
            street_component = [item for item in split_address if Address.num_and_char(item) or item.isnumeric()][0]
        except IndexError:
            street_component = ''
        return Address.split_alphanum(street_component)
    
    @staticmethod
    def extract_apartment(split_address):
        if '#' in ''.join(split_address):
            apartment_component = ''.join(item for item in split_address if '#' in item).replace('#', '')
        else:
            last_component = split_address[-1]
            if Address.num_and_char(last_component) or len(last_component) == 1 and last_component not in ('n','s','e','w'):
                apartment_component = last_component
            else:
                apartment_component = '' 
        return Address.split_alphanum(apartment_component)
        
    def __repr__(self):
        return ' '.join((self.street_number, *self.street, self.apartment)).strip()
    



if __name__ == '__main__':

    pass


# In[3]:


#collect data to train model
path1 = r"C:\Users\T461561\Downloads\Zz_checking after additions.txt"
path2 = r"C:\Users\T461561\Downloads\Zz_banking after additions.txt"

col_names = ['SourceFirstName', 'SourceLastName','SourceFirstName2','SourceLastName2','LookupFirstName','LookupLastName','LookupFirstName2','LookupLastName2','SourceAddress','LookupAddress','HardMatch','MatchCode','MatchReasonCode','NameMatchProb', 'Yar','AddrMatchProb','MatchReason','SourceRecord','AddressLookupRecord', 'Hardmatch']

file1 = pd.read_csv(path1, header=0)
file2 = pd.read_csv(path2, header=0)


files = [file1, file2]
#matchcodes for manual matching
manualalpha = ["A", "B", "C", "D", "T", "U"]

manualnum = ["1","2","3","4","5", "6", "7"]
manual = []
for i in manualalpha:
    for j in manualnum:
        manual.append(i+j)

        
manual.remove("A1")
manual.remove("A2")
manual.remove("A7")
manual.remove("U5")
manual.remove("U6")
manual.remove("U7")

#changing matchreasoncode from A3 or A6 to their percentage of hardmatch equalling 1
path_matchreasoncode = r"C:\Users\T461561\Downloads\dict_matchreason.csv"
file_matchreasoncode = read_csv(path_matchreasoncode, header = None, index_col=0,skiprows=0).T.to_dict()
#checking output

#def group_list(lst): 
      
#    return list(zip(Counter(lst).keys(), Counter(lst).values())) 

#res = group_list(column)
#res


# In[43]:


empty = file2['SourceFirstName'][0]
import math
math.isnan(empty)


# In[35]:



def parse_address(line):
    try:
        parse = Address(line)
        street_parse = parse.street
        apt_parse = parse.apartment
        street_no_parse = parse.street_number
    except:
        street_parse = ''
        apt_parse = ''
        street_no_parse = ''
    return street_parse, street_no_parse, apt_parse
def get_fuzzy_score(input1, input2):
    if (input1 == empty or input2 == empty):
        fuzzy_score = 0
    else:
        try:
            fuzzy_score = (fuzz.ratio(input1,input2))
        except:
            fuzzy_score = 0
        
    return fuzzy_score
def process_company(input1):
    try:
        input1.replace(" llc","")
        input1.replace(" co","")
        input1.replace(" inc","")
        input1.replace("service","svc")
        input1.replace("servs","svc")
        input1.replace("serv","svc")
        input1.replace("association","assn")
        input1.replace("assoc","assn")
    except:
        input1 = input1
    return input1
    


# In[36]:


#only adding in manual matching reason codes
def filter_zz_tables(files):
    filter_file = []
    for file in files:
        for index, rows in file.iterrows():
            if (rows[12] in manual):
                holder_list = [rows[i] for i in range(len(rows))]
                filter_file.append(holder_list)
    

    #fuzzy wuzzy ratios
    for row in range(len(filter_file)):
    #first name matching
    #SourceFirstNames vs LookupFirstNames
        firstname1 = get_fuzzy_score(filter_file[row][0],filter_file[row][4])
        firstname2 = get_fuzzy_score(filter_file[row][2],filter_file[row][4])
        firstname3 = get_fuzzy_score(filter_file[row][0],filter_file[row][6])
        firstname4 = get_fuzzy_score(filter_file[row][2],filter_file[row][6])
        
    #taking the max of the first name ratios
        firstname = max(firstname1, firstname2, firstname3, firstname4)
        
        
    #SourceLastNames vs LookupLastNames
        lastname1 = get_fuzzy_score(process_company(filter_file[row][1]),process_company(filter_file[row][5]))
        lastname2 = get_fuzzy_score(process_company(filter_file[row][3]),process_company(filter_file[row][5]))
        lastname3 = get_fuzzy_score(process_company(filter_file[row][1]),process_company(filter_file[row][7]))
        lastname4 = get_fuzzy_score(process_company(filter_file[row][3]),process_company(filter_file[row][7]))
        
    #taking the max of the last name ratios
        lastname = max(lastname1, lastname2, lastname3, lastname4)
    
        filter_file[row].append(firstname)
        filter_file[row].append(lastname)
    #Fuzzy address match using MatchReason
        source_street, source_street_no, source_apt = parse_address(filter_file[row][8])
        lookup_street, lookup_street_no, lookup_apt = parse_address(filter_file[row][9])
        if (filter_file[row][15][0:4] == "Unit"):
            try:
                address1 = (fuzz.token_sort_ratio(filter_file[row][8], filter_file[row][9]))
                address2 = 0
                address3 = 0
            except:
                address1 = 0
                address2 = 0
                address3 = 0
        else:
            try:
                address1 = (fuzz.ratio(source_street, lookup_street))
            except:
                address1 = 0
            try:
                address2 = (fuzz.ratio(source_steet_no, lookup_street_no))
            except:
                address2 = 0
            try:
                address3 = (fuzz.ratio(source_apt, lookup_apt))
            except:
                address3 = 0
            try:
                address1_3 =(fuzz.ratio(source_street+source_apt, lookup_street+lookup_apt))
            except:
                address1_3 = 0
        #max out address1 scores to see if apartment got fracked
        address1 = max(address1,address1_3)
        #average out scores for the three fuzzy matches
        if (source_apt == '' and lookup_apt == '' ):
            address = (address1 + address2)/2
        else:
            address = (address1 + address2 + address3)/3
        filter_file[row].append(address)
        print(filter_file[row])
    
  #creating a cut down version of zz_outputs that only includes variables to be passed into ML
    filtered_filter_file = []

    for row in range(len(filter_file)):
        filtered_filter_file.append([filter_file[row][12],filter_file[row][13],filter_file[row][14],filter_file[row][-3],filter_file[row][-2],filter_file[row][-1],filter_file[row][10]])
    list_dataset = filtered_filter_file
    for row in range(len(filtered_filter_file)):
        MatchReasonCode = filtered_filter_file[row][0]
        list_dataset[row][0] = file_matchreasoncode[MatchReasonCode][1]

    return list_dataset


# In[15]:


def zz_output_table(files):
    #returns only manually matched match reason codes into one large file
    filter_file = []
    #filter_file.append(files[0].columns.tolist())
    for file in files:
        for index, rows in file.iterrows():
            if (rows[12] in manual):
                holder_list = [rows[i] for i in range(len(rows))]
                filter_file.append(holder_list)
    return filter_file


# In[37]:


#split up dataset into 80:20 split with hardmatch as the y value
start_time = time.time()
dataset = pd.DataFrame(filter_zz_tables(files), columns = ['MatchReasonPercentage', 'NameMatch', 'AddressMatch','FirstNameFuzz','LastNameFuzz','AddressFuzz','HardMatch'])
print("%s seconds" % (time.time() - start_time))
      
array = dataset.values
X = array[:,0:6].astype(float)
y = array[:,6].astype(float)
X_train, X_validation, Y_train, Y_validation = train_test_split(X, y, test_size=0.20, random_state=1)


# In[74]:


# Spot Check Algorithms
models = []
models.append(('LR', LogisticRegression(solver='liblinear', multi_class='ovr')))
models.append(('LDA', LinearDiscriminantAnalysis()))
models.append(('KNN', KNeighborsClassifier()))
models.append(('CART', DecisionTreeClassifier()))
models.append(('NB', GaussianNB()))
#models.append(('SVM', SVC(gamma='auto')))
models.append(('RF', RandomForestClassifier()))
# evaluate each model in turn
results = []
names = []
for name, model in models:
    start_time = time.time()
    kfold = StratifiedKFold(n_splits=10, random_state=1, shuffle=True)
    cv_results = cross_val_score(model, X_train, Y_train, cv=10, scoring='accuracy')
    results.append(cv_results)
    names.append(name)
    print('%s: %f (%f)' % (name, cv_results.mean(), cv_results.std()))
    print("--- %s seconds ---" % (time.time() - start_time))


# In[63]:


# Compare Algorithms
pyplot.boxplot(results, labels=names)
pyplot.title('Algorithm Comparison')
pyplot.show()


# In[38]:


#Optimize decision tree and check for overfitting
models_opt = []
#default decision tree
models_opt.append(('reg',RandomForestClassifier()))
for i in range(15,26):
    models_opt.append(('RF'+str(i), RandomForestClassifier(max_depth = i)))

results_op = []
names_op = []
for name, model in models_opt:
    kfold = StratifiedKFold(n_splits=10, random_state=1, shuffle=True)
    cv_results = cross_val_score(model, X_train, Y_train, cv=10, scoring='accuracy')
    results_op.append(cv_results)
    names_op.append(name)
    print('%s: %f (%f)' % (name, cv_results.mean(), cv_results.std()))


# In[11]:


# Comparing Decision Trees
pyplot.boxplot(results_op, labels=names_op)
pyplot.title('Forest Comparison')
pyplot.show()


# In[41]:


# Make predictions on validation dataset
model = RandomForestClassifier(max_depth = 18)
model.fit(X_train, Y_train)
predictions = model.predict(X_validation)
print(accuracy_score(Y_validation, predictions))


# In[44]:



with open('model.pickle', 'wb') as handle:
    pickle.dump(model, handle, protocol=pickle.HIGHEST_PROTOCOL)

with open('model.pickle', 'rb') as handle:
    model = pickle.load(handle)


# In[14]:


path_zz_output_mail = r"X:\TD Bank Checking\TD Bank (Checking 2020)\TDB-493 (CHECKING - SEPT 2020)\Response Tracking\2020.10.13 match - automated VZ\Address Match\zz_mail output (shortened sr).txt"
path_zz_output_ctrl = r"X:\TD Bank Checking\TD Bank (Checking 2020)\TDB-493 (CHECKING - SEPT 2020)\Response Tracking\2020.10.13 match - automated VZ\Address Match\zz_ctrl output (shortened sr).txt"



file_zz_output_mail = pd.read_csv(path_zz_output_mail, delimiter = '\t')
file_zz_output_ctrl = pd.read_csv(path_zz_output_ctrl, delimiter = '\t')

col_names = ['SourceFirstName', 'SourceLastName','SourceFirstName2','SourceLastName2','LookupFirstName','LookupLastName','LookupFirstName2','LookupLastName2','SourceAddress','LookupAddress','HardMatch','MatchCode','MatchReasonCode','NameMatchProb','AddrMatchProb','MatchReason','SourceRecord','AddressLookupRecord']


files_MTTSB = []
files_MTTSB.append(file_zz_output_mail)
files_MTTSB.append(file_zz_output_ctrl)
#if (Num_zz_tables_4 == True):
#    files_NM.append(file_zz_output_mail2)
#    files_NM.append(file_zz_output_ctrl2)

MTTSB_list = filter_zz_tables(files_MTTSB)

dataset_MTTSB = pd.DataFrame(MTTSB_list, columns = ['MatchReasonPercentage', 'NameMatch', 'AddressMatch','FirstNameFuzz','LastNameFuzz','AddressFuzz','HardMatch'])

array_MTTSB = dataset_MTTSB.values
X_MTTSB = array_MTTSB[:,0:6]
y_MTTSB = array_MTTSB[:,6]
predictions_MTTSB = model.predict(X_MTTSB)
print(accuracy_score(y_MTTSB, predictions_MTTSB))
print(confusion_matrix(y_MTTSB, predictions_MTTSB))
zz_table_MTT = zz_output_table(files_MTTSB)
zz_table_MTT.insert(0,col_names)
output_path = r"C:\Users\T461561\Downloads\manual_matched_TDVZ.txt"

for row in range(len(predictions_MTTSB)):
    zz_table_MTT[row][10] = predictions_MTTSB[row]


with open(output_path, 'w', newline='') as outfile:
    writer = csv.writer(outfile)
    for row in zz_table_MTT:
        writer.writerow(row)


# In[91]:


#collect data to apply model
path_zz_output_mail = r"C:\Users\T461561\Downloads\zz_mail BOTW NM output.txt"
path_zz_output_ctrl = r"C:\Users\T461561\Downloads\zz_ctrl BOTW NM output.txt"
path_zz_output_mail2 = r"C:\Users\T461561\Downloads\zz_mail mailing BOTW NM output.txt"
path_zz_output_ctrl2 = r"C:\Users\T461561\Downloads\zz_ctrl mailing BOTW NM output.txt"

Num_zz_tables_4 = True

file_zz_output_mail = pd.read_csv(path_zz_output_mail, header=0, delimiter = '\t')
file_zz_output_ctrl = pd.read_csv(path_zz_output_ctrl, header=0, delimiter = '\t')
file_zz_output_mail2 = pd.read_csv(path_zz_output_mail2, header=0, delimiter = '\t')
file_zz_output_ctrl2 = pd.read_csv(path_zz_output_ctrl2, header=0, delimiter = '\t')

files_NM = []
files_NM.append(file_zz_output_mail)
files_NM.append(file_zz_output_ctrl)
if (Num_zz_tables_4 == True):
    files_NM.append(file_zz_output_mail2)
    files_NM.append(file_zz_output_ctrl2)

NM_list = filter_zz_tables(files_NM)


dataset_NM = pd.DataFrame(NM_list, columns = ['MatchReasonPercentage', 'NameMatch', 'AddressMatch','FirstNameFuzz','LastNameFuzz','AddressFuzz','HardMatch'])

array_NM = dataset_NM.values
X_NM = array_NM[:,0:6]
y_NM = array_NM[:,6]
predictions_NM = model.predict(X_NM)
print(accuracy_score(y_NM, predictions_NM))
print(confusion_matrix(y_NM, predictions_NM))


# In[ ]:


list_output = zz_output_table(files)


# In[86]:


#collect data
path_test = r"C:\Users\T461561\Downloads\Zz_BBT_May.txt"



file_test = pd.read_csv(path_test, header=0)
files_test = []
files_test.append(file_test)
#file2 = pd.read_csv(path2, header=0)



list_test = filter_zz_tables(files_test)

dataset_test = pd.DataFrame(list_test, columns = ['MatchReasonPercentage', 'NameMatch', 'AddressMatch','FirstNameFuzz','LastNameFuzz','AddressFuzz','HardMatch'])

array_test = dataset_test.values
X_test = array_test[:,0:6]
y_test = array_test[:,6]
predictions_test = model.predict(X_test)
print(accuracy_score(y_test, predictions_test))
print(confusion_matrix(y_test, predictions_test))


# In[18]:


bbttest = pd.DataFrame(filter_zz_tables(file_test), columns = ['MatchReasonPercentage', 'NameMatch', 'AddressMatch','FirstNameFuzz','LastNameFuzz','AddressFuzz','HardMatch'])


array_test = dataset_test.values
X_test = array_test[:,0:6]
y_test = array_test[:,6]
predictions_test = model.predict(X_test)
print(accuracy_score(y_test, predictions_test))


# In[19]:


output_bbt = zz_output_table(files_test)
output_bbt[0].append('Predictions')
for row in range(len(output_bbt) -1):
    output_bbt[row+1].append(predictions_test[row])

output_nm = zz_output_table(files_NM)
output_nm[0].append('Predictions')
for row in range(len(output_nm) -1):
    output_nm[row+1].append(predictions_NM[row])


# In[20]:



    
output_path = r"C:\Users\T461561\Downloads\prediction_v_actual_BBT.txt"

with open(output_path, 'w', newline='') as outfile:
    writer = csv.writer(outfile)
    for row in output_bbt:
        writer.writerow(row)
    
output_path = r"C:\Users\T461561\Downloads\prediction_v_actual_NM.txt"

with open(output_path, 'w', newline= '') as outfile:
    writer = csv.writer(outfile)
    for row in output_nm:
        writer.writerow(row)


# In[30]:


#collect data to apply model
path_zz_output_mail = r"C:\Users\T461561\Downloads\zz_mail output NMTCF.txt"
path_zz_output_ctrl = r"C:\Users\T461561\Downloads\zz_ctrl output NMTCF.txt"
#path_zz_output_mail2 = r"C:\Users\T461561\Downloads\zz_mail mailing BOTW NM output.txt"
#path_zz_output_ctrl2 = r"C:\Users\T461561\Downloads\zz_ctrl mailing BOTW NM output.txt"

Num_zz_tables_4 = False

file_zz_output_mail = pd.read_csv(path_zz_output_mail, delimiter = '\t')
file_zz_output_ctrl = pd.read_csv(path_zz_output_ctrl, delimiter = '\t')
#file_zz_output_mail2 = pd.read_csv(path_zz_output_mail2, header=0, delimiter = '\t')
#file_zz_output_ctrl2 = pd.read_csv(path_zz_output_ctrl2, header=0, delimiter = '\t')

files_NMTCF = []
files_NMTCF.append(file_zz_output_mail)
files_NMTCF.append(file_zz_output_ctrl)
#if (Num_zz_tables_4 == True):
#    files_NM.append(file_zz_output_mail2)
#    files_NM.append(file_zz_output_ctrl2)

NMTCF_list = filter_zz_tables(files_NMTCF)


dataset_NMTCF = pd.DataFrame(NMTCF_list, columns = ['MatchReasonPercentage', 'NameMatch', 'AddressMatch','FirstNameFuzz','LastNameFuzz','AddressFuzz','HardMatch'])

array_NMTCF = dataset_NMTCF.values
X_NMTCF = array_NMTCF[:,0:6]
y_NMTCF = array_NMTCF[:,6]
predictions_NMTCF = model.predict(X_NMTCF)
print(accuracy_score(y_NMTCF, predictions_NMTCF))
print(confusion_matrix(y_NMTCF, predictions_NMTCF))


# In[34]:


def process_zz_tables(files):
    #removes non manually matched 
    filter_list = filter_zz_tables(files)
    dataset = pd.DataFrame(filter_list, columns = ['MatchReasonPercentage', 'NameMatch', 'AddressMatch','FirstNameFuzz','LastNameFuzz','AddressFuzz','HardMatch'])
    array = dataset.values
    X_func = array[:,0:6]
    predictions = model.predict(X_func)
    col_names = ['SourceFirstName', 'SourceLastName','SourceFirstName2','SourceLastName2','LookupFirstName','LookupLastName','LookupFirstName2','LookupLastName2','SourceAddress','LookupAddress','HardMatch','MatchCode','MatchReasonCode','NameMatchProb','AddrMatchProb','MatchReason','SourceRecord','AddressLookupRecord']
    output = zz_output_table(files)
    better_output = []
    for row in output:
        better_output.append(row[0:18])
    for row in range(len(predictions)):
        better_output[row][10] = predictions[row]
    manual_output = pd.DataFrame(better_output, columns = col_names)
    manual_output['SourceRecord'] = manual_output['SourceRecord'].astype(int)#removes decimal values from the source record
    manual_output['Concatenated'] = manual_output['SourceRecord'].astype(str) + manual_output['AddressLookupRecord']
    #manual_output.fillna('', inplace=True)
    #output_path = str(Path(path_zz_output_mail).parent) + r'\Processed_Manual_Matches.txt'
    #manual_output.to_csv(output_path, sep ='\t', index = False)
    return manual_output


# In[35]:


#collect data to apply model
path_zz_output_mail = r"C:\Users\T461561\Downloads\zz_mail output BBTBB.txt"
path_zz_output_ctrl = r"C:\Users\T461561\Downloads\zz_ctrl output BBTBB.txt"
path_zz_output_mail2 = r"C:\Users\T461561\Downloads\zz_mail output BBTBB2.txt"
path_zz_output_ctrl2 = r"C:\Users\T461561\Downloads\zz_ctrl output BBTBB2.txt"

Num_zz_tables_4 = True

file_zz_output_mail = pd.read_csv(path_zz_output_mail, header=0, delimiter = '\t')
file_zz_output_ctrl = pd.read_csv(path_zz_output_ctrl, header = 0,delimiter = '\t')
file_zz_output_mail2 = pd.read_csv(path_zz_output_mail2, header=0, delimiter = '\t')
file_zz_output_ctrl2 = pd.read_csv(path_zz_output_ctrl2, header=0, delimiter = '\t')

files_BBTBB = []
files_BBTBB.append(file_zz_output_mail)
files_BBTBB.append(file_zz_output_ctrl)
if (Num_zz_tables_4 == True):
    files_BBTBB.append(file_zz_output_mail2)
    files_BBTBB.append(file_zz_output_ctrl2)

    
    
BBTBB_list = filter_zz_tables(files_BBTBB)


dataset_BBTBB = pd.DataFrame(BBTBB_list, columns = ['MatchReasonPercentage', 'NameMatch', 'AddressMatch','FirstNameFuzz','LastNameFuzz','AddressFuzz','HardMatch'])

array_BBTBB = dataset_BBTBB.values
X_BBTBB = array_BBTBB[:,0:6]
y_BBTBB = array_BBTBB[:,6]
predictions_BBTBB = model.predict(X_BBTBB)
print(accuracy_score(y_BBTBB, predictions_BBTBB))
print(confusion_matrix(y_BBTBB, predictions_BBTBB))
manual_matched = process_zz_tables(files_BBTBB)


# In[33]:


path_zz_output_mail = r"C:\Users\T461561\Downloads\zz_mail output TD DDA.txt"
path_zz_output_ctrl = r"C:\Users\T461561\Downloads\zz_ctrl output TD DDA.txt"


file_zz_output_mail = pd.read_csv(path_zz_output_mail, delimiter = '\t')
file_zz_output_ctrl = pd.read_csv(path_zz_output_ctrl, delimiter = '\t')
#file_zz_output_mail2 = pd.read_csv(path_zz_output_mail2, header=0, delimiter = '\t')
#file_zz_output_ctrl2 = pd.read_csv(path_zz_output_ctrl2, header=0, delimiter = '\t')

files_TDDDA = []
files_TDDDA.append(file_zz_output_mail)
files_TDDDA.append(file_zz_output_ctrl)

output_tddda = process_zz_tables(files_TDDDA)


manual_matched = output_tddda

manual_matched


# In[29]:


#collect data to apply model
path_zz_output_mail = r"C:\Users\T461561\Downloads\zz_mail output TD DDA.txt"
path_zz_output_ctrl = r"C:\Users\T461561\Downloads\zz_ctrl output TD DDA.txt"


file_zz_output_mail = pd.read_csv(path_zz_output_mail, delimiter = '\t')
file_zz_output_ctrl = pd.read_csv(path_zz_output_ctrl, delimiter = '\t')
#file_zz_output_mail2 = pd.read_csv(path_zz_output_mail2, header=0, delimiter = '\t')
#file_zz_output_ctrl2 = pd.read_csv(path_zz_output_ctrl2, header=0, delimiter = '\t')

files_TDDDA = []
files_TDDDA.append(file_zz_output_mail)
files_TDDDA.append(file_zz_output_ctrl)
#if (Num_zz_tables_4 == True):
#    files_NM.append(file_zz_output_mail2)
#    files_NM.append(file_zz_output_ctrl2)

TDDDA_list = filter_zz_tables(files_TDDDA)


dataset_TDDDA = pd.DataFrame(TDDDA_list, columns = ['MatchReasonPercentage', 'NameMatch', 'AddressMatch','FirstNameFuzz','LastNameFuzz','AddressFuzz','HardMatch'])

array_TDDDA = dataset_TDDDA.values
X_TDDDA = array_TDDDA[:,0:6]
y_TDDDA = array_TDDDA[:,6]
predictions_TDDDA = model.predict(X_TDDDA)
print(accuracy_score(y_TDDDA, predictions_TDDDA))
print(confusion_matrix(y_TDDDA, predictions_TDDDA))


# In[15]:


path_zz_output_mail = r"C:\Users\T461561\Downloads\zz_mail output PNC SB.txt"
path_zz_output_ctrl = r"C:\Users\T461561\Downloads\zz_ctrl output PNC SB.txt"



file_zz_output_mail = pd.read_csv(path_zz_output_mail, delimiter = '\t')
file_zz_output_ctrl = pd.read_csv(path_zz_output_ctrl, delimiter = '\t')


files_PNCSB = []
files_PNCSB.append(file_zz_output_mail)
files_PNCSB.append(file_zz_output_ctrl)
#if (Num_zz_tables_4 == True):
#    files_NM.append(file_zz_output_mail2)
#    files_NM.append(file_zz_output_ctrl2)

PNCSB_list = filter_zz_tables(files_PNCSB)


dataset_PNCSB = pd.DataFrame(PNCSB_list, columns = ['MatchReasonPercentage', 'NameMatch', 'AddressMatch','FirstNameFuzz','LastNameFuzz','AddressFuzz','HardMatch'])

array_PNCSB = dataset_PNCSB.values
X_PNCSB = array_PNCSB[:,0:6]
y_PNCSB = array_PNCSB[:,6]
predictions_PNCSB = model.predict(X_PNCSB)
print(accuracy_score(y_PNCSB, predictions_PNCSB))
print(confusion_matrix(y_PNCSB, predictions_PNCSB))


# In[20]:


mail = file_zz_output_mail

mail['AddrMatchProb'] = mail['AddrMatchProb'].astype(int)
mail['Concatenated'] = mail['AddrMatchProb'].astype(str) + mail['MatchReason']



mail.iloc[:,14] = manual_matched.reset_index().merge(mail, how='left', left_on=['Concatenated'], right_on=['Concatenated']).iloc[:,12]

#manual_output.fillna('', inplace=True)
    #output_path = str(Path(path_zz_output_mail).parent) + r'\Processed_Manual_Matches.txt'
    #manual_output.to_csv(output_path, sep ='\t', index = False)
    
#mail.fillna('',inplace =True)
#mail.to_csv('mail_overwrite.txt', sep='\t', index=False)


# In[18]:


mail_untouched = file_zz_output_mail
#mail_untouched.to_csv('mail_untouched.txt', sep ='\t', index=False)
mail_untouched


# In[48]:


col_names = ['SourceFirstName', 'SourceLastName','SourceFirstName2','SourceLastName2','LookupFirstName','LookupLastName','LookupFirstName2','LookupLastName2','SourceAddress','LookupAddress','HardMatch','MatchCode','MatchReasonCode','NameMatchProb','AddrMatchProb','MatchReason','SourceRecord','AddressLookupRecord']
    
try:
    file_zz_output_mail['SourceFirstName']
except:
    file_zz_output_mail = pd.read_csv(path_zz_output_mail, header = None, names = col_names, delimiter = '\t')
    
file_zz_output_mail


# In[151]:


mail = file_zz_output_mail
mail.columns
mail.iloc[:,14]


# In[60]:


predictions = manual_matched['HardMatch']
concatenated = manual_matched['Concatenated']
predictionary  = {}
for item in range(len(concatenated)):
    predictionary[concatenated[item]] = predictions[item]
    
manual_matched_identifiers = predictionary.keys()

if (type(file_zz_output_mail['SourceRecord']) == float):
    file_zz_output_mail['SourceRecord'] = file_zz_output_mail['SourceRecord'].astype(int)#removes decimal values from the source record
file_zz_output_mail['Concatenated'] = file_zz_output_mail['SourceRecord'].astype(str) + file_zz_output_mail['AddressLookupRecord']
    
mail_dataset = file_zz_output_mail.values
mail_dataset[10][10]


# In[63]:


for row in mail_dataset:
    if (row[18] in manual_matched_identifiers):
        row[10] = predictionary[row[18]]
mail_dataset


# In[69]:


mail_dataset2 = file_zz_output_mail.values

truths = mail_dataset[:,10] == mail_dataset2[:,10]
truths.all == True

