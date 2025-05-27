import sys
from pathlib import Path
import os

sys.path.insert(0, str(Path(__file__).parent.parent))

from extraction.mercadolivre.script.get_seller_shipping_cost import get_shipping_id

def test_shipping_extraction():
    test_results = get_shipping_id(test_run=True)

    print("On test function:")
    print(test_results["id"], type(test_results["id"]))
    assert test_results["id"] == os.environ["SHIPPING_ID_TEST_1"]
    assert test_results["list_cost"] == os.environ["LIST_COST"]