from pythonosc.udp_client import SimpleUDPClient
import time
import random
import pickle
from config import settings
from song import song_machine

song_client = SimpleUDPClient(settings.ip, settings.SONG_SERVER_PORT)
processing_client = SimpleUDPClient(settings.ip, settings.AUDIENCE_PORT)
texts = ['Dies ist der nullte Kommentar von Mock_Interpreter_Client',
         'Dies ist der erste Kommentar',
         'der zweite Kommentar',
         'der dritte Kommentar von Mock_Interpreter_Client. '
         'Ich weiss gar nicht mehr, wann ich das letzte Mal so richtig viel geschrieben habe',
         'Dies ist der vierte und finite Kommentar von Mock_Interpreter_Client',
         'Wie naiv gehts noch?',
         'Rational betrachtet ist das wirklich sehr überraschend. Vor 10 Jahren hätte diese Meldung noch Lachkrämpfe hervorgerufen.',
         'Einerseits technisch und taktisch echt bewandert, andererseits viele unfair und unsportliche Seiten.',
         'Dreist und überheblich! ... und null Chance.',
         'Sie haben aber schon mit bekommen, wer da so mobilisiert?',
         'der begriff "kultureller genozid " scheint mir ein un-ding,',
         'Falsch. Es geht genau ums Gegenteil',
         'Ich glaube, dass das Unsinn ist.',
         'Finde ich eigentlich ganz gut, wenn so auch mal Sachen ausprobiert werden, die sich vor COVID-19 keiner hätte vorstellen können.',
         'APPLAUS!',
         'Das ist Mittlerweile Parteiübergreifend unbestritten.',
         'Da ist doch nicht gegen einzuwenden.',
         'Und da liegt in meinen Augen auch das Problem: Der random "Fan", der einfach zu ungebildet ist was den Charakter des MMA Sports angeht.',
         'Ist beim Joghurt wenig sinnvoll. Das Töten der Bakterien.',
         'Jeder Staatsbedienstete ist verpflichtet sich an Recht und Gesetz zu halten, sonst kann er persönlich in Haftung genommen werden.',
         'Was ist das für ein Stuss was hier im Forum abgesondert wird?',
         'Müssten Verwaltungsrichter an vorderster Front stehen, würden sie nämlich nicht solche Urteilen fällen....',
         'Damit wird auch der Klau von Autos,Baumaschinen und E-Bikes  in Deutschland sprunghaft sinken.']


def run_mock():
    machine = song_machine.create_instance(settings.song_path)
    categories = list(machine.category_counter.keys())

    while True:
        key = input('Bitte cat auswaehlen (1-5)')
        if key in ['1', '2', '3', '4', '5', 'r']:
            if not key == 'r':
                cat = categories[int(key)-1]
                osc_dict = {'text': random.sample(texts, 1)[0],
                            'cat': cat,
                            }
                osc_map = pickle.dumps(osc_dict)
                song_client.send_message(settings.INTERPRETER_TARGET_ADDRESS, osc_map)
            else:
                cat = 'reset'
                song_client.send_message(settings.SONG_SYNTH_RESET_ADDRESS, cat)
        else:
            print('wrong key: ', key)


if __name__ == "__main__":
    run_mock()
