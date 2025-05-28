import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from cleaning.adjust_cost_data import clean_cost_data

def test_cleaning():
    print("\n=================== test_cleaning.py started ===================")
    test_result = clean_cost_data(test_run = True)

    assert test_result["begin_date_type"] == "datetime64[ns, UTC]"
    assert test_result["end_date_type"] == "datetime64[ns, UTC]"
    assert test_result["begin_date_nulls"] == 0
    assert test_result["cost_nulls_nans"] == 0
    print("=================== test_cleaning.py finished ===================")
