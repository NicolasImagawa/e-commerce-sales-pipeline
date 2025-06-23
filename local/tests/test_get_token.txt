import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from extraction.mercadolivre.script.get_access_token import get_access_token

def test_get_token():
    test_results = get_access_token(test_run=True)

    assert test_results == True
