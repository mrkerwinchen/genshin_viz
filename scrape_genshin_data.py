import pandas as pd
import requests
from bs4 import BeautifulSoup

def extract_info(n, data):
    '''
    extract summary information on character based on position in the table
    found on the genshin-impact website
    '''
    to_do = {
        0 : (lambda x: x.find("img").attrs),                         # Image
        1 : (lambda x: x.text.strip().replace(" ", "_")),            # Name
        2 : (lambda x: int(x.find("img").attrs["alt"].split()[0])),  # Rarity
        3 : (lambda x: x.text.strip()),                              # Type
        4 : (lambda x: x.text.strip()),                              # Weapon
        5 : (lambda x: x.text.strip()),                              # Sex
        6 : (lambda x: x.text.strip())                               # Nation
    }
    return to_do[n](data)


root_url = "https://genshin-impact.fandom.com/wiki/"
characters_request = requests.get(root_url + "Characters/List")
characters_html = BeautifulSoup(characters_request.text, 'html.parser')
character_table = characters_html.find_all('table')[0]

print('extracting summary info...')
character_dict = {}
#extract summary info for each character
for i, row in enumerate(character_table.find_all('tr')):
    character_info = [extract_info(n, data) for n, data in enumerate(row.find_all('td'))]
    character_dict[i] = character_info
print('done')

character_df = pd.DataFrame.from_dict(data = character_dict,
                                      orient = "index",
                                      columns = ["img", "name", "rarity", "type", "weapon", "sex", "nation"])

character_df = (character_df
                .drop(index = 0, columns = ["img"])
                .drop(index = character_df.loc[character_df["name"] == 'Traveler'].index)
                .reset_index(drop = True))
character_df.to_csv("viz_app/data/character_summary.csv")

all_HP = {}
all_ATK = {}
all_DEF = {}

print('extracting statistics for each character...')
#Extracting statistics for each character strength (ATK, HP, DEF)
for i, c in enumerate(character_df["name"]):
    if i % 10 == 0: print(f'starting character {i}: {c}...')
    character_prof = requests.get(root_url + c)
    prof_html = BeautifulSoup(character_prof.text, 'html.parser')
    stats_table = prof_html.find_all('table')
    c_HP = []; c_ATK = []; c_DEF = []

    for row in stats_table[6].find_all('tr'):
        row_data = row.find_all('td')
        data = lambda n: int(row_data[n].text.replace(",", ""))
        if len(row_data) != 0:
            c_HP.append(data(1))
            c_ATK.append(data(2))
            c_DEF.append(data(3))
    all_HP[c] = c_HP
    all_ATK[c] = c_ATK
    all_DEF[c] = c_DEF
print('done')

#Correcting errors found in the data
all_HP["Kaedehara_Kazuha"][5] = 6902
all_DEF["Kaedehara_Kazuha"][5] = 417

level = [1, 20, 20, 40, 40, 50, 50, 60, 60, 70, 70, 80, 80, 90]
level_df = pd.DataFrame(level, columns = ["Level"])

pd.concat([level_df, pd.DataFrame.from_dict(all_ATK)], axis=1).to_csv("viz_app/data/all_ATK.csv")
pd.concat([level_df, pd.DataFrame.from_dict(all_HP)], axis=1).to_csv("viz_app/data/all_HP.csv")
pd.concat([level_df, pd.DataFrame.from_dict(all_DEF)], axis=1).to_csv("viz_app/data/all_DEF.csv")
print('all data extracted')
