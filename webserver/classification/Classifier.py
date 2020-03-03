import os
import re
import joblib
from webserver.classification import preprocessing


class Classifier:
    def __init__(self, data_dir):
        self.clf = joblib.load(os.path.join(data_dir, 'sgd_clf.pkl'))
        self.regex_mapping = joblib.load(os.path.join(data_dir, 'regex_mapping.pkl'))
        self.filter_stop_words = False

    def check_sent_with_regex(self, sentence):
        for exp, cat in self.regex_mapping.items():
            if re.search(exp, sentence):
                return cat, 1.0
        return None

    def predict_proba(self, sentence, filter_stop_words=False):
        self.filter_stop_words = filter_stop_words
        sentence = preprocessing.clean_string(sentence)

        regex_pred = self.check_sent_with_regex(sentence)
        if regex_pred is not None:
            return regex_pred

        vector = preprocessing.sentence_to_vec(sentence, filter_stop_words=self.filter_stop_words)
        if vector is None:
            return ['Not classifiable', 1]
        else:
            probas = self.clf.predict_proba([vector])[0]
            max_index = probas.argmax()

            return self.clf.classes_[max_index], probas[max_index]
