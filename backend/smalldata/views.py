import time

from rest_framework import viewsets
from .serializers import UtteranceSerializer, CategorySerializer
from .models import Utterance, Category

from classification.Classifier_max import Classifier
from sound.MusicServer03 import COND1
from sound.UDPClient import Client_MusicServer
from sound.rules import SIMPLE_NOTES


clf = Classifier('../model_data')
# Client for a simple Feedback from Ableton Live
music_client = Client_MusicServer('127.0.0.1', 5015, COND1)


class UtteranceView(viewsets.ModelViewSet):
    serializer_class = UtteranceSerializer
    queryset = Utterance.objects.all()

    def perform_create(self, serializer):
        #  TODO: First detect the correct category,
        #Fetch sent data:
        text = serializer.validated_data["text"]
        # send text to clf to return a category
        cat, prob = clf.predict_proba(text, verbose=True)
        print('cat: {}\nproba {}'.format(cat, prob))
        # lookup found category in database
        category_name = str(cat)
        category = Category.objects.all().filter(name=category_name)[0]
        serializer.validated_data["category"] = category
        #  Second, send the category to the music server
        note = SIMPLE_NOTES[cat]
        print('note: ', note)
        music_client.msg_send(note, 100, 1.0)
        time.sleep(1)
        music_client.msg_send(note, 100, 0.0)
        #display found category in the app
        super(UtteranceView, self).perform_create(serializer)


class CategoryView(viewsets.ModelViewSet):
    serializer_class = CategorySerializer
    queryset = Category.objects.all()
