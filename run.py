import subprocess
import os
import json
import argparse
from config import settings
import joblib
from song.song_machine import SongValidator


def check_model_song_cats():
    #  validate consistency of trained model and song
    with open(settings.song_path, 'r') as f:
        json_data = json.load(f)
    song_validator = SongValidator(json_data)
    song_validator.validate()
    song_categories = song_validator.categories

    clf = joblib.load(os.path.join(settings.DATA_DIR, 'sgd_clf.pkl'))

    missing_cats = []
    for clf_cat in clf.classes_:
        if clf_cat not in song_categories:
            missing_cats.append(clf_cat)

    if missing_cats:
        raise Exception('Categories are inconsistent: {} not in song'.format(missing_cats))


parser = argparse.ArgumentParser()
parser.add_argument('app')
parser.add_argument('--skip-checks', help='skip consistency checks', action="store_true")
args = parser.parse_args()

if not args.skip_checks:
    check_model_song_cats()

if args.app == 'backend':
    p = subprocess.check_call(["python", "webserver/manage.py", "runserver"])
elif args.app == 'song':
    from pythonosc import udp_client
    from song import song_machine
    from song.song_server import SongServer, BeatAdvanceManager

    oscul_client = udp_client.SimpleUDPClient(settings.ip, settings.OSCULATOR_PORT)
    disp_client = udp_client.SimpleUDPClient(settings.ip, settings.PROCESSING_PORT)

    machine_instance = song_machine.create_instance(settings.song_path)
    beat_manager = BeatAdvanceManager(machine_instance.parser.first_state_name)

    song_server = SongServer(oscul_client, disp_client, machine_instance, beat_manager)
    song_parts = list(machine_instance.parser.states.keys())
    [disp_client.send_message('/parts', part) for part in song_parts]
    disp_client.send_message('/parts', 'all_sent')
    song_server.server.serve_forever()
elif args.app == 'frontend':
    os.chdir('frontend')
    p = subprocess.check_call(["npm", "start"])
elif args.app == 'display':
    from song.display.playhead import Playhead
    from song.display.song_status import SongStatus
    from song.display.display_server import DisplayServer, BeatAdvanceManager
    from song.display.surfaces import Beat, Utterances, PartInfo
    import asyncio

    playhead = Playhead()
    #  TODO use actula states of song
    song_surface = SongStatus(settings.song_file, ["intro", "scene02", "scene03"], playhead)
    beat_manager = BeatAdvanceManager()
    utterances_surface = Utterances()
    beat_surface = Beat()
    partinfo_surface = PartInfo()
    display_server = DisplayServer(beat_manager, song_surface, utterances_surface, beat_surface, partinfo_surface)

    loop = asyncio.get_event_loop()
    result = loop.run_until_complete(display_server.init_main())
elif args.app == 'interpreter':
    from mocks import mock_interpreter_client
    mock_interpreter_client.run_mock()
elif args.app == 'osculator':
    from mocks import beat_mock
    beat_mock.run_mock()
elif args.app == 'trainer':
    from webserver.classification import trainer
    import pandas as pd
    data_path = 'webserver/model_data'

    regexes = trainer.load_regexes(os.path.join(data_path, 'TrainingData_regex.xlsx'))
    df_ml = pd.read_excel(os.path.join(data_path, 'TrainingData_ml.xlsx')).rename(columns={'Effekt': 'category'})
    sentences, categories = trainer.read_trainingdata_utterances(df_ml)
    x, y = trainer.vectorize_corpus(sentences, categories=categories)
    clf = trainer.train_clf(x, y)

    joblib.dump(regexes, os.path.join(data_path, 'regex_mapping.pkl'))
    joblib.dump(clf, os.path.join(data_path, 'sgd_clf.pkl'))

else:
    raise Exception('Unknown command: {}. Please see run.py for options'.format(args.app))
