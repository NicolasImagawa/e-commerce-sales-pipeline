import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from extraction.mercadolivre.script.send_data import postgres_ingestion_ml

def test_load_ml():
    test_results = postgres_ingestion_ml(test_run=True)

    assert test_results == 1