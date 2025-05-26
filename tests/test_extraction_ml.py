import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from tests.test_extraction_ml import extract_mercado

def test_extraction():
    test_results = extract_mercado()

    assert test_results["orders_range"] == True
    assert test_results["all_csv"] == True
