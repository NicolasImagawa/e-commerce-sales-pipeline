# About the scripts

All the files are orchstrated with Apache Airflow.

- IaC: executes the terraform files;
- Cleaning: cleans and adjusts the product costs that must be provided by the user. It also has a file to remember any product relations that might be necessary for specific cases defined by the user.
- Deletion: Deletes the entry tables and the extracted files that were loaded to the data warehouse.
- Extraction: Includes the scripts for both platforms to extract data. Currently, the Shopee API does not work, so the data must be extracted manually through .xlsx files.
- Loading: This folder has the code to load data to the warehouse.
- Transformation: Holds all the files needed to transform the data using dbt.
