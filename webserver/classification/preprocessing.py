import numpy as np
from gensim.parsing import preprocessing as gsp
import spacy
import gensim
import os

nlp = spacy.load('de')
model = gensim.models.KeyedVectors.load_word2vec_format(
        os.path.join(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))),  # the parent dir of the file
            'model_data/german.model'), binary=True
)


def clean_string(text):
    filters = [replace_umlaut,
               gsp.strip_tags,
               gsp.strip_multiple_whitespaces,
               gsp.strip_numeric]
    text = text.lower()

    for f in filters:
        text = f(text)
    return text.strip()


def replace_umlaut(text):
    text = text.replace('ä', 'ae')
    text = text.replace('ö', 'oe')
    text = text.replace('ü', 'ue')
    text = text.replace('ß', 'ss')
    return text


def word_to_vec(word):
    word = str(word)
    if word in model.index2word:
        return model.word_vec(word)
    elif word.capitalize() in model.index2word:
        return model.word_vec(word.capitalize())
    else:
        return None


def sentence_to_vec(sentence, filter_stop_words=False):
    """
    Warning: returns None, if none of the words in the sentence are known to the model!
    :param sentence:
    :param filter_stop_words: Boolean
    :return: center of gravity of the vector representation of the (mappable) words in the sentence
    """
    data_matrix = []
    for word in nlp(sentence):
        if not (word.is_stop and filter_stop_words):  # ignore stopwords if filter_stop_words=True
            vec = word_to_vec(word)
            if vec is not None:  # ignore words that are not contained in the language model
                data_matrix.append(vec)

    if len(data_matrix) > 0:
        return np.mean(np.asarray(data_matrix), axis=0)  # return center of gravity
