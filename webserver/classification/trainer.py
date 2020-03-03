"""
creates two pickle files.
1) single word vector classifier
2) regex mapping.


"""
import numpy as np
import pandas as pd

from pathlib import Path
from collections import defaultdict

from sklearn.linear_model import SGDClassifier
from sklearn.model_selection import cross_val_score

import warnings

from webserver.classification.preprocessing import clean_string, sentence_to_vec, word_to_vec

warnings.filterwarnings("ignore")


def vectorize_corpus(texts, categories=None):
    """
    :param texts: a list of texts
    :param categories: an optional list of categories. If provided, a new list of categories is returned,
                        with the cats of the texts removed that have not been vectorized
    :return: an array of vectors. WARNING: if a text cannot be vectorized, it is removed from the corpus!
    """
    if categories is not None and len(texts) != len(categories):
        raise Exception('category and texts input must be of the same shape')

    vectors = []
    return_cats = []
    for idx, text in enumerate(texts):
        vect = sentence_to_vec(text)
        if vect is not None:
            vectors.append(vect)
            if categories is not None:
                return_cats.append(categories[idx])

    if categories:
        return np.asarray(vectors), np.asarray(return_cats)
    else:
        return np.asarray(vectors)


def read_trainingdata_textfiles(trainingdata_path):
    """
    Reads all trainingdata texfiles in a directory. The textfiles can contain single words and regular expressions.
    Every line containing more than one word ist considered a regular expression
    lines starting with "[" are ignored.
    An example trainingdata file could look like this:

    [words]
    word1
    word2

    [regexes]
    word .* another three words
    ^Begin .* like this


    The function returns 2 dictionaries:  One with single words as keys and categories as values
                                          One with regexes as keys and categories as values

    all umlauts are replaced and words are lowercases.
    """
    keywords_to_cat = defaultdict(list)
    regexes = {}

    for file in Path(trainingdata_path).iterdir():
        if file.suffix == '.txt':
            category = file.stem
            text = file.read_text()
            for keywords in text.split('\n'):
                keywords = keywords.strip()
                keywords = keywords.lower()
                keywords = clean_string(keywords)
                if keywords and keywords[0] != '[':
                    if len(keywords.split(' ')) == 1:
                        keywords_to_cat[keywords].append(category)
                    else:
                        regexes[keywords] = category

    return keywords_to_cat, regexes


def read_trainingdata_utterances(df, min_wc=1, max_wc=np.Inf):
    print('\nReading trainingdata')
    df = df.drop_duplicates(['utterance'])  # avoid duplication
    x = []
    y = []

    for i in df.index:
        utt = df['utterance'][i]
        if not isinstance(df['category'][i], float):
            text = clean_string(utt)
            wc = len(text.split(' '))  # word_count
            if min_wc <= wc <= max_wc:
                x.append(text)
                y.append(df['category'][i])

    return x, y


def transform_keywords_to_trainingdata(keywords_to_cat):
    """
    Transforms a dictionary mapping keywords to categories into two lists that can be used
    to train sklearn SGDClassifier objects. Words are transformed into Word2Vec Vectors using
    a gensim model trained on the german Wikipedia
    """
    x, y = [], []
    # print('139 keywords2cat: ', keywords_to_cat)

    for word, category in keywords_to_cat.items():
        vect = word_to_vec(word)
        if vect is not None:
            x.append(vect)
            y.append(category)

    x = np.asarray(x)
    y = np.asarray(y)

    return x, y


def train_clf(x, y):
    clf = None
    best = 0
    print('\nTraining SGD Classifier')
    for i in range(200):
        temp_clf = SGDClassifier(tol=1e-3, max_iter=1000, random_state=i, loss='modified_huber')
        # print('x: {}\ny: {} '.format(x, y))
        score = np.mean(cross_val_score(temp_clf, x, y, cv=5, scoring='f1_weighted'))
        temp_clf.fit(x, y)

        if score > best:
            best = score
            clf = temp_clf
    print('\nAverage F1 Score {: .2f}%'.format(np.mean(best) * 100))
    return clf


def load_regexes(file_path):
    print('\nBuilding regexes')
    df = pd.read_excel(file_path)
    expressions = map(clean_string, df.utterance)
    return dict(zip(expressions, df.Effekt))
