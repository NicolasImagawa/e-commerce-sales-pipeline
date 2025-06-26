def delete_input_files(path: str, file_extension: str) -> None:
    from pathlib import Path

    # paths = [
    #     "/opt/airflow/extraction/mercadolivre/data/raw/*.json",
    #     "/opt/airflow/extraction/mercadolivre/data/shipping_cost_ml/*.json",
    #     "/opt/airflow/extraction/shopee/data/raw/*.xlsx",
    #     "/opt/airflow/extraction/mercadolivre/data/clean/shipping_ids_mercadolivre.csv"
    # ]

    abs_path = Path(path)

    for files in abs_path.glob(file_extension):
        try:
            files.unlink()
            print(f"Deleted all files in {path} with extension {file_extension}")
        except Exception as e:
            print(f"Failed to delete files in {path} with error: {e}")
