# -*- coding: utf-8 -*-
"""
Created on Tue Jul  7 15:53:25 2015

@author: nate
"""
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegressionCV
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.cross_validation import train_test_split

shootings_filt = []

for num in list(range(1,5 + 1)):
    df = shootings[shootings['justified'] == num]
    shootings_filt.append(df)

data = pd.concat(shootings_filt)

data = data[['justified','mental_illness','state','gender_male','age','race_black','race_white','race_hispanic','race_asian','race_nativeamer']]

dummies = pd.DataFrame(pd.get_dummies(data['state']))

X = pd.concat([data.drop('state', 1), dummies], axis = 1).dropna()

y = X['justified']
X = X.drop('justified',1)

X_train, X_test, y_train, y_test = train_test_split(X, y)

model_rf = RandomForestClassifier(n_estimators = 25, max_depth = 2500, n_jobs = -1)
model_rf.fit(X_train, y_train)
rf_predict = model_rf.predict(X_test)

model_lr = LogisticRegressionCV(Cs = [0.01,.1, 1, 2.5, 5, 10], cv = 100)
model_lr.fit(X_train, y_train)
lr_predict = model_lr.predict(X_test)

model_gbm = GradientBoostingClassifier(loss = 'deviance', n_estimators = 1000, max_depth = 5)
model_gbm.fit(X_train, y_train)
gbm_predict = model_gbm.predict(X_test)

predictions = pd.DataFrame({'actual': y_test, 'rf_predict':rf_predict, \
                            'lr_predict':lr_predict,'gbm_predict':gbm_predict})
predictions['avg_predict'] = (predictions['lr_predict'] + predictions['rf_predict'] + predictions['gbm_predict']) / 3
predictions['rf_error'] = abs(predictions['actual'] - predictions['rf_predict'])
predictions['lr_error'] = abs(predictions['actual'] - predictions['lr_predict'])
predictions['gbm_error'] = abs(predictions['actual'] - predictions['gbm_predict'])
predictions['avg_error'] = abs(predictions['actual'] - predictions['avg_predict'])
predictions['avg_predict_rnd'] = predictions['avg_predict'].map(lambda x: round(int(x) , 0))

# predictions[['rf_error','lr_error','gbm_error','avg_error']].mean()
# for num in [1,2,3,4,5]:
#    pred_sub = predictions[predictions['actual'] == num]
#    print(num)
#    print(pred_sub[['rf_error','lr_error','gbm_error','avg_error']].mean())