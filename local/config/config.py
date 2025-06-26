DBT_PROFILE_PATH = "/opt/airflow/dbt_files/e_commerce_sales"
DBT_PROJECT_PATH = "/opt/airflow/dbt_files/e_commerce_sales"

TEST_PROFILE_PATH = "./local/dbt_files/e_commerce_sales/tests"
TEST_PROJECT_PATH = "./local/dbt_files/e_commerce_sales"

PATHS = {
    'adjust_cost_data': {
        'test': {
            'cost_data_path': "./local/data/supplies/unit_test/raw/raw_sample.csv",
            'output_path': "./local/data/supplies/unit_test/clean/clean_sample.csv",
            
        },
        'prod': {
            'cost_data_path': "/opt/airflow/data/supplies/raw/prod/cost_data.csv",
            'output_path': "/opt/airflow/data/supplies/clean/prod/clean_cost_data.csv"
        },
        'dev': {
            'cost_data_path': "/opt/airflow/data/supplies/raw/dev/dev_cost_data.csv",
            'output_path': "/opt/airflow/data/supplies/clean/dev/dev_clean_cost_data.csv"
        }
    },

    'create_shipping_id_list': {
        'test': {
            'save_path': "./local/data/mercadolivre/shipping_cost_ml/dev/shipping_ids_mercadolivre.csv"
        },
        'prod': {
            'save_path': "/opt/airflow/data/mercadolivre/shipping_cost_ml/prod/shipping_ids_mercadolivre.csv"
        },
        'dev': {
            'save_path': "/opt/airflow/data/mercadolivre/shipping_cost_ml/dev/shipping_ids_mercadolivre.csv"
        }
    },

    'extract_ml_data': {
        'test': {
            'dotenv_path': "./local/.env",
            'download_path': "./local/data/mercadolivre/raw/dev/ml_sell_data_"
        },
        'prod_and_dev': {
            'dotenv_path': "/opt/airflow/.env"
        },

        'prod': {
            'download_path': "/opt/airflow/data/mercadolivre/raw/prod/ml_sell_data_"
        },

        'dev': {
            'dotenv_path': "/opt/airflow/data/mercadolivre/shipping_cost_ml/dev/shipping_ids_mercadolivre.csv",
            'download_path': "/opt/airflow/data/mercadolivre/raw/dev/ml_sell_data_"
        }
    },

    'extract_seller_shipping_cost': {
        'test': {
            'id_path': "./local/data/mercadolivre/shipping_cost_ml/dev/shipping_ids_mercadolivre.csv",
            'save_suffix': "./local/data/mercadolivre/shipping_cost_ml/dev/"
        },

        'prod': {
            'id_path': "/opt/airflow/data/mercadolivre/shipping_cost_ml/prod/shipping_ids_mercadolivre.csv",
            'save_suffix': "/opt/airflow/data/mercadolivre/shipping_cost_ml/prod/"
        },

        'dev': {
            'id_path': "/opt/airflow/data/mercadolivre/shipping_cost_ml/dev/shipping_ids_mercadolivre.csv",
            'save_suffix': "/opt/airflow/data/mercadolivre/shipping_cost_ml/dev/"
        }
    },

    'get_access_token': {
        'test': {
            'dotenv_path': "./local/.env",
        },

        'prod_and_dev': {
            'dotenv_path': "/opt/airflow/.env"
        }
    },

    'load_data_ml': {
        'test': {
            'dir': "./local/data/mercadolivre/raw/dev/sample.json",

        },

        'prod': {
            'dir': "/opt/airflow/data/mercadolivre/raw/prod/"
        },

        'dev': {
            'dir': "/opt/airflow/data/mercadolivre/raw/dev/"
        }
    },

    'load_shipping_cost': {
        'prod': {
            'path': "/opt/airflow/data/mercadolivre/shipping_cost_ml/prod/"
        },

        'dev': {
            'path': "/opt/airflow/data/mercadolivre/shipping_cost_ml/dev/"
        }
    },

    'load_data_shopee': {
        'test': {
            'dir': "./local/shopee/data/sample/sample.xlsx",

        },

        'prod': {
            'dir': "/opt/airflow/data/shopee/raw/prod/"
        },

        'dev': {
            'dir': "/opt/airflow/data/shopee/raw/dev/"
        }
    },

    'load_kits': {
        'prod': {
            'path': "/opt/airflow/data/supplies/clean/prod/kit_components.csv"
        },

        'dev': {
            'path': "/opt/airflow/data/supplies/clean/dev/dev_kit_components.csv"
        }
    },

    'load_prices': {
        'prod': {
            'path': "/opt/airflow/data/supplies/clean/prod/clean_cost_data.csv"
        },

        'dev': {
            'path': "/opt/airflow/data/supplies/clean/dev/dev_clean_cost_data.csv"
        }
    },

}

ENTRY_TABLES_NAMES = [
    "entry.entry_mercadolivre",
    "entry.entry_mercadolivre__context__flows",
    "entry.entry_mercadolivre__mediations",
    "entry.entry_mercadolivre__order_items",
    "entry.entry_mercadolivre__order_items__item__variation_attributes",
    "entry.entry_mercadolivre__payments",
    "entry.entry_mercadolivre__payments__available_actions",
    "entry.entry_mercadolivre__tags",
    "entry.entry_mercadolivre_sh",
    "entry.entry_mercadolivre_sh__destination__shipping_address__types",
    "entry.entry_mercadolivre_sh__items_types",
    "entry.entry_mercadolivre_sh__origin__shipping_address__types",
    "entry.entry_mercadolivre_sh__tags",
    "entry.entry_shopee",
    "entry._dlt_loads",
    "entry._dlt_pipeline_state",
    "entry._dlt_version"
]