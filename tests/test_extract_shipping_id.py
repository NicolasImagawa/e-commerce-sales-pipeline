import sys
from pathlib import Path
import os

sys.path.insert(0, str(Path(__file__).parent.parent))

from extraction.mercadolivre.script.get_seller_shipping_cost import get_shipping_id

def test_shipping_extraction():
    print("\n=================== test_extract_shipping_id.py started ===================")

    test_results = get_shipping_id(test_run=True)

    print("On test function:")
    print(test_results)
    print(test_results["id"], type(test_results["id"]))
    
    assert test_results["id"] == int(os.environ["SHIPPING_ID_TEST_1"])
    assert test_results["list_cost"] == int(os.environ["LIST_COST"])

    print("=================== test_extract_shipping_id.py finished ===================")