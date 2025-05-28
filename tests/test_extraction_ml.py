import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from extraction.mercadolivre.script.extract_data import extract_mercado

def test_extraction():
    print("=================== test_extraction_ml.py started ===================")
    test_results = extract_mercado(test_run=True)

    assert test_results["orders_range"] == True
    assert test_results["all_json"] == True
    print("=================== test_extraction_ml.py finished ===================")
