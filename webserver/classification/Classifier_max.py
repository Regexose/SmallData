import os
import re
import spacy
import gensim
import joblib
import numpy as np
from collections import defaultdict
from webserver.classification import preprocessing


class Classifier:
    '''
    A Word2Vec based Text classifier. It classifies sentences into one of several sentiment categories.
    It uses a mix of regular expression and wordvector based SVM classification.
    '''

    def __init__(self, data_dir):
        '''
        Initializes a trained classifier. the specified data data directory needs to contain on gensim model
        called "german.model", one trained sklearn SGD Classifier called "sgd_clf.pkl" and one
        dictionary mapping regular expressions to sentiment categories calles "regex_mapping.pkl"
        '''
        self.model = gensim.models.KeyedVectors.load_word2vec_format(os.path.join(data_dir, 'german.model'),
                                                                     binary=True)
        self.clf = joblib.load(os.path.join(data_dir, 'sgd_clf.pkl'))
        self.nlp = spacy.load('de')
        self.regex_mapping = joblib.load(os.path.join(data_dir, 'regex_mapping.pkl'))
        self.filter_stop_words = False
        self.verbose = False

    def word_to_vect(self, word):
        word = str(word)
        if word in self.model.index2word:
            return self.model.word_vec(word)
        elif word.capitalize() in self.model.index2word:
            return self.model.word_vec(word.capitalize())
        else:
            return None

    def sent_to_vect(self, sentence, ):
        sentence = self.nlp(sentence)
        return np.array([self.word_to_vect(word) for word in sentence if not (word.is_stop and self.filter_stop_words)])

    def classify_sent_vect(self, vector):
        if vector is not None:
            vector = [e for e in vector if e is not None]
            preds, probas = [], []
            for elem in vector:
                pred = self.clf.predict([elem])
                proba = [max(prob_arr) for prob_arr in self.clf.predict_proba([elem])]
                preds.append(pred[0])
                probas.append(proba[0])
            return zip(preds, probas)
        return None

    def check_sent_with_vector_clf(self, sentence):
        vects = self.sent_to_vect(sentence)
        preds_and_probas = self.classify_sent_vect(vects)
        return preds_and_probas

    def check_sent_with_regex(self, sentence):
        for exp, cat in self.regex_mapping.items():
            if re.search(exp, sentence):
                if self.verbose:
                    print('Regex matched: {} (category: {})'.format(exp, cat))
                return cat, 1.0
        return None

    @staticmethod
    def aggregate_vector_preds(preds_and_probas):
        ranking = defaultdict(list)

        for pred, proba in preds_and_probas:
            ranking[pred].append(proba)

        agg = [(pred, sum(probas)/len(probas)) for pred, probas in ranking.items()]
        return sorted(agg, key=lambda t: t[1], reverse=True)

    def get_similar_words(self, word):
        if word in self.model.index2word:
            for sim in self.model.most_similar(word):
                print(sim)
        elif word.capitalize() in self.model.index2word:
            for sim in self.model.most_similar(word.capitalize()):
                print(sim)
        else:
            print('das Wort kenne ich nicht')

    def predict_proba(self, sentence, filter_stop_words=True, verbose=False):
        self.verbose = verbose
        self.filter_stop_words = filter_stop_words
        sentence = preprocessing.clean_string(sentence)
        regex_pred = self.check_sent_with_regex(sentence)

        if regex_pred is not None:
            return regex_pred

        clf_preds = self.check_sent_with_vector_clf(sentence)
        clf_preds = [p for p in clf_preds if p is not None]
        print('regex_pred: {}, clf_preds: {}'.format(regex_pred, clf_preds))

        if clf_preds:
            sorted_preds = self.aggregate_vector_preds(clf_preds)
            return sorted_preds[0]
        else:
            return ('Gaga', 1.0)