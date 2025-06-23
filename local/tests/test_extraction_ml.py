import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from local.extraction.mercadolivre.script.extract_ml_data import extract_mercado

def test_extraction():
    print("\n=================== test_extraction_ml.py started ===================")
    
    date_init_1 = "2024-07-01T00:00:00.000-03:00"
    date_end_1 = "2024-08-01T00:00:00.000-03:00"
    test_results_1 = extract_mercado(test_run=True, order_init_date = date_init_1, order_end_date = date_end_1)

    date_init_2 = "2024-08-01T00:00:00.000-03:00"
    date_end_2 = "2024-07-01T00:00:00.000-03:00"
    test_results_2 = extract_mercado(test_run=True, order_init_date = date_init_2, order_end_date = date_end_2)

    assert test_results_1["orders_range"] == True
    assert test_results_1["all_json"] == True
    assert test_results_2["orders_range"] == False
    assert test_results_2["all_json"] == False


    print("=================== test_extraction_ml.py finished ===================")
