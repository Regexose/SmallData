from django.urls import re_path

from webserver.smalldata import consumers

websocket_urlpatterns = [
    # We use re_path() due to limitations in URLRouter.
    re_path(r"ws/utterance", consumers.UtteranceConsumer.as_asgi()),
]