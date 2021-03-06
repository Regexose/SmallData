import pickle
import random

from django.http import JsonResponse

from rest_framework import viewsets
from .serializers import UtteranceSerializer, CategorySerializer, TrainingUtteranceSerializer
from .models import Utterance, Category, TrainingUtterance

from webserver.classification.Classifier_max import Classifier
from webserver.sound.UDPClient import MusicClient
from config import settings

clf = Classifier(settings.DATA_DIR)
#   Client for a simple Feedback from Ableton Live
song_client = MusicClient(settings.ip, settings.SONG_SERVER_PORT)
display_client = MusicClient(settings.ip, settings.AUDIENCE_PORT)


def send_to_music_server(utterance, category):
    osc_dict = {
        'text': utterance,
        'cat': category,
        'f_dura': random.randint(0, 10)
    }
    osc_map = pickle.dumps(osc_dict)
    song_client.send_message(settings.INTERPRETER_TARGET_ADDRESS, osc_map)
    # display_client.send_message(settings.DISPLAY_UTTERANCE_ADDRESS, [utterance, category])


class UtteranceView(viewsets.ModelViewSet):
    serializer_class = UtteranceSerializer
    queryset = Utterance.objects.all()

    def perform_create(self, serializer):
        #  First detect the correct category,
        # Fetch sent data:

        text = serializer.validated_data["text"]
        # send text to clf to return a category
        cat, prob = clf.predict_proba(text, verbose=True)

        # lookup found category in database
        #  TODO: build a test during startup to make sure the db and the model reproduce the same categories!
        categories = Category.objects.all().filter(name=str(cat))
        if not categories:  # if db is inconsistent with model, just use any cat
            categories = Category.objects.all()
            print('WARNING: no matching category in db! Using random assignment')
        category = categories[0]
        serializer.validated_data["category"] = category

        #  save result in db
        super(UtteranceView, self).perform_create(serializer)
        print('cat: {}\ntext {}'.format(category.name, text))

        send_to_music_server(text.encode("utf-8"), category.name)


class CategoryView(viewsets.ModelViewSet):
    serializer_class = CategorySerializer
    queryset = Category.objects.all()


class TrainingUtteranceView(viewsets.ModelViewSet):
    serializer_class = TrainingUtteranceSerializer
    queryset = TrainingUtterance.objects.all()


def trigger_category(request, pk):
    if request.method == 'POST':
        category = Category.objects.get(pk=pk)
        text = 'test text, um eine Kategorie zu starten!'
        send_to_music_server(text, category.name)

        return JsonResponse(data={'status': 'true', 'message': 'ok'})
