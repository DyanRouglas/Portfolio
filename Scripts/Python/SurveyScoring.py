#!/usr/bin/env python
# coding: utf-8

# In[99]:


import pandas as pd
import numpy as np
import matplotlib as plt
import math


# In[137]:


def score_bdi(bdi):
    Score = []
    for i, row in bdi.iterrows():
        ID = row['autonumber']
        event_name = row['redcap_event_name']
        BDI_score = sum(row['bdi1':'bdi21'])
        if BDI_score <= 13:
            BDI_category = 0
        elif BDI_score > 13 and BDI_score <= 19:
            BDI_category = 1
        elif BDI_score > 19 and BDI_score <= 28:
            BDI_category = 2
        elif BDI_score > 28 and BDI_score <= 63:
            BDI_category = 3
        else:
            BDI_category = np.nan

        entry = {
            'StudyID': ID,
            'EventName': event_name,
            'BDI_score': BDI_score,
            'BDI_category': BDI_category
        }
        Score.append(entry)

    return pd.DataFrame(Score)


def score_bis11(bis):
    Score = []
    recode_cols = ['bis1', 'bis5', 'bis6', 'bis7', 'bis8', 'bis10', 'bis11', 'bis13', 'bis17',
                  'bis19', 'bis22', 'bis30']
    for col in recode_cols:
        for i in bis.index:
                score =bis.loc[i, col]
                if score == 1:
                    bis.loc[i, col] = 4
                elif score == 2:
                    bis.loc[i, col] = 3
                elif score == 3:
                    bis.loc[i, col] = 2
                elif score == 4:
                    bis.loc[i, col] = 1
                else:
                    bis.loc[i, col] = np.nan

    for i, row in bis.iterrows():
        ID = row['autonumber']
        event_name = row['redcap_event_name']



        NonPlanningImpulsiveness = 11 * np.nanmean([row['bis1'], row['bis5'], row['bis6'], row['bis8'], row['bis10'], row['bis13'],
                                                row['bis16'], row['bis28']])

        CognitiveImpulsiveness = 8 * np.nanmean([row['bis4'], row['bis7'], row['bis19'], row['bis27'], row['bis29']])

        MotorImpulsiveness = 11 * np.nanmean([row['bis2'], row['bis3'], row['bis14'], row['bis15'], row['bis18'], row['bis20'], row['bis21'],
                                       row['bis25'], row['bis30']])

        bis11TotalScore = 30 * np.nanmean([row['bis1'], row['bis2'], row['bis3'], row['bis4'], row['bis5'], row['bis6'],
                                           row['bis7'], row['bis8'], row['bis10'], row['bis11'], row['bis12'], row['bis13'],
                                           row['bis14'], row['bis15'], row['bis16'],row['bis18'], row['bis19'], row['bis20'],
                                           row['bis21'], row['bis25'], row['bis27'], row['bis28'], row['bis29'], row['bis30']])

        CognitiveSubscale = 15 * np.nanmean([row['bis1'], row['bis2'], row['bis3'], row['bis5'], row['bis6'],
                                             row['bis7'], row['bis8'], row['bis10'], row['bis11'], row['bis17'],
                                             row['bis19'], row['bis22'], row['bis29'], row['bis30']])

        IdeomotorSubscale = 15 * np.nanmean([row['bis4'], row['bis9'], row['bis12'], row['bis14'], row['bis15'], row['bis16'], row['bis18'],
                                     row['bis20'], row['bis21'], row['bis23'], row['bis24'], row['bis25'], row['bis26'], row['bis27']])

        entry = {
            'StudyID': ID,
            'EventName': event_name,
            'NonPlanningImpulsiveness': NonPlanningImpulsiveness,
            'CognitiveImpulsiveness': CognitiveImpulsiveness,
            'MotorImpulsiveness': MotorImpulsiveness,
            'bis11TotalScore': bis11TotalScore,
            'CognitiveSubscale': CognitiveSubscale,
            'IdeomotorSubscale': IdeomotorSubscale
        }

        Score.append(entry)
    return pd.DataFrame(Score)


def score_ctq(ctq):

    Score = []
    recode_cols = ['ctq02', 'ctq05', 'ctq07', 'ctq13', 'ctq19', 'ctq26', 'ctq28']
    recode_cols5_0 = ['ctq10', 'ctq16', 'ctq22']

    for col in recode_cols:
        for i in ctq.index:
            score = ctq.loc[i, col]

            if score == 1:
                ctq.loc[i, col] = 5
            elif score == 2:
                ctq.loc[i, col] = 4
            elif score == 4:
                ctq.loc[i, col] = 2
            elif score == 5:
                ctq.loc[i, col] = 1
            else:
                ctq.loc[i, col] = np.nan

    for col in recode_cols5_0:
        for i in ctq.index:
            score = ctq.loc[i, col]
            if score == 5:
                ctq.loc[i, col] = 1
            else:
                ctq.loc[i, col] = 0

    for i, row in ctq.iterrows():
        ID = row['autonumber']
        event_name = row['redcap_event_name']

        Sexual_Abuse_Score= sum([row['ctq20'], row['ctq21'], row['ctq23'], row['ctq24'],  row['ctq27']])
        Physical_Abuse_Score= sum([row['ctq09'], row['ctq11'], row['ctq12'], row['ctq15'],  row['ctq17']])
        Emotional_Abuse_Score= sum([row['ctq03'], row['ctq08'], row['ctq14'], row['ctq18'],  row['ctq25']])
        Emotional_Neglect_Score= sum([row['ctq05'], row['ctq07'], row['ctq13'], row['ctq19'],  row['ctq28']])
        Physical_Neglect_Score= sum([row['ctq01'], row['ctq02'], row['ctq04'], row['ctq06'],  row['ctq26']])
        Idealization_of_Childhood= sum([row['ctq10'], row['ctq16'], row['ctq22']])

        SexAbuseUpdated = 5 * np.nanmean([row['ctq20'], row['ctq21'], row['ctq23'], row['ctq24'], row['ctq27']])
        EmoAbuseUpdated = 5 * np.nanmean([row['ctq03'], row['ctq08'], row['ctq14'], row['ctq18'], row['ctq25']])
        PhyAbuseUpdated = 5 * np.nanmean([row['ctq09'], row['ctq11'], row['ctq12'], row['ctq15'], row['ctq17']])
        EmoNeglectUpdated = 5 * np.nanmean([row['ctq05'], row['ctq07'], row['ctq13'], row['ctq19'], row['ctq28']])
        PhyNeglectUpdated = 5 * np.nanmean([row['ctq01'], row['ctq02'], row['ctq04'], row['ctq06'], row['ctq26']])

        if Sexual_Abuse_Score <= 5:
            Sexual_Abuse_Category = 0
        elif Sexual_Abuse_Score > 5 and Sexual_Abuse_Score <= 7:
            Sexual_Abuse_Category = 1
        elif Sexual_Abuse_Score > 7 and Sexual_Abuse_Score <= 12:
            Sexual_Abuse_Category = 2
        elif Sexual_Abuse_Score > 12:
            Sexual_Abuse_Category = 3
        else:
            Sexual_Abuse_Category = np.nan


        if Physical_Abuse_Score <= 7:
            Physical_Neglect_Category = 0
        elif Physical_Abuse_Score > 7 and Physical_Abuse_Score <= 9:
            Physical_Neglect_Category= 1
        elif Physical_Abuse_Score > 9 and Physical_Abuse_Score <= 12:
            Physical_Neglect_Category= 2
        elif Physical_Abuse_Score > 12:
            Physical_Neglect_Category= 3
        else:
            Physical_Neglect_Category = np.nan

        if Emotional_Neglect_Score <= 9:
            Emotional_Neglect_Category = 0
        elif Emotional_Neglect_Score > 9 and Emotional_Neglect_Score <= 14:
            Emotional_Neglect_Category= 1
        elif Emotional_Neglect_Score > 14 and Emotional_Neglect_Score <= 17:
            Emotional_Neglect_Category= 2
        elif Emotional_Neglect_Score > 17:
            Emotional_Neglect_Category= 3
        else:
            Emotional_Neglect_Category = np.nan

        if Emotional_Abuse_Score <= 8:
            Emotional_Abuse_Category= 0
        elif Emotional_Abuse_Score > 8 and Emotional_Abuse_Score <= 12:
            Emotional_Abuse_Category= 1
        elif Emotional_Abuse_Score > 12 and Emotional_Abuse_Score <= 15:
            Emotional_Abuse_Category= 2
        elif Emotional_Abuse_Score > 15:
            Emotional_Abuse_Category= 3
        else:
            Emotional_Abuse_Category = np.nan


        entry = {
            'StudyID': ID,
            'EventName': event_name,
            'Sexual_Abuse_Score':Sexual_Abuse_Score,
            'Physical_Abuse_Score':Physical_Abuse_Score,
            'Emotional_Abuse_Score': Emotional_Abuse_Score,
            'Emotional_Neglect_Score':Emotional_Neglect_Score,
            'Physical_Neglect_Score':Physical_Neglect_Score,
            'Idealization_of_Childhood':Idealization_of_Childhood,
            'SexAbuseUpdated':SexAbuseUpdated,
            'EmoAbuseUpdated':EmoAbuseUpdated,
            'PhyAbuseUpdated':PhyAbuseUpdated,
            'EmoNeglectUpdated':EmoNeglectUpdated,
            'PhyNeglectUpdated':PhyNeglectUpdated,
            'Sexual_Abuse_Category':Sexual_Abuse_Category,
            'Physical_Neglect_Category':Physical_Neglect_Category,
            'Emotional_Neglect_Category':Emotional_Neglect_Category,
            'Emotional_Abuse_Category':Emotional_Abuse_Category
        }

        Score.append(entry)
    return pd.DataFrame(Score)


def score_ders(ders):

    Score = []

    for i, row in ders.iterrows():
        ID = row['autonumber']
        event_name = row['redcap_event_name']

        DERS_Nonacceptance= sum([row['ers29'], row['ers25'], row['ers15'], row['ers14'], row['ers33'], row['ers27']])
        DERS_Goals= sum([row['ers30'], row['ers22'], row['ers16'], row['ers38'], row['ers24']])
        DERS_Impulse= sum([row['ers37'], row['ers31'], row['ers17'], row['ers23'], row['ers4'], row['ers28']])
        DERS_Awareness= sum([row['ers7'], row['ers3'], row['ers12'], row['ers21'], row['ers9'], row['ers39']])
        DERS_Strategies= sum([row['ers20'], row['ers19'], row['ers35'], row['ers40'], row['ers32'], row['ers26'],
                             row['ers41'], row['ers1']])
        DERS_Clarity= sum([row['ers6'], row['ers5'], row['ers10'], row['ers8'], row['ers1']])

        entry = {
            'StudyID': ID,
            'EventName': event_name,
            'DERS_Nonacceptance':DERS_Nonacceptance,
            'DERS_Goals':DERS_Goals,
            'DERS_Impulse':DERS_Impulse,
            'DERS_Awareness':DERS_Awareness,
            'DERS_Strategies':DERS_Strategies,
            'DERS_Clarity':DERS_Clarity
        }

        Score.append(entry)

    return pd.DataFrame(Score)


def score_pss(pss):

    Score = []

    recode_cols = ['pss4', 'pss5', 'pss6', 'pss7', 'pss9', 'pss10']

    for col in recode_cols:
        for i in pss.index:
            score = pss.loc[i, col]

            if score == 0:
                pss.loc[i, col] = 4
            elif score == 1:
                pss.loc[i, col] = 3
            elif score == 3:
                pss.loc[i, col] = 1
            elif score == 4:
                pss.loc[i, col] = 0
            else:
                pss.loc[i, col] = np.nan


    for i, row in pss.iterrows():
        ID = row['autonumber']
        event_name = row['redcap_event_name']

        PSS_score = 14 * np.nanmean([row['pss1'], row['pss2'], row['pss3'], row['pss4'], row['pss5'], row['pss6'],
                                    row['pss7'], row['pss8'], row['pss9'], row['pss10'], row['pss11'], row['pss12'],
                                    row['pss13'], row['pss12']])

        entry = {
            'StudyID': ID,
            'EventName': event_name,
            'PSS_score':PSS_score
        }

        Score.append(entry)

    return pd.DataFrame(Score)


def score_stait(stait):

    Score = []

    for i, row in stait.iterrows():
        ID = row['autonumber']
        event_name = row['redcap_event_name']

        stait_score = np.nanmean([row['stai1'], row['stai2'], row['stai3'], row['stai4'], row['stai5'],
                                 row['stai6'], row['stai7'], row['stai8'], row['stai9'], row['stai10'],
                                 row['stai11'], row['stai12'], row['stai13'], row['stai14'], row['stai15']])

        entry = {
            'StudyID': ID,
            'EventName': event_name,
            'stait_score':stait_score
        }

        Score.append(entry)

    return pd.DataFrame(Score)





# In[ ]:
