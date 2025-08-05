import sys
import logging
import boto3
import time
import pathlib
import os

S3_BUCKET          = 'e-commerce-sales-bucket' #Your S3 Bucket Name
TEMP_FILE_PREFIX   = 'redshift_data_upload' #Temporary file prefix
REDSHIFT_WORKGROUP = 'e-commerce-workgroup'
REDSHIFT_DATABASE  = 'dev' #default "dev"
MAX_WAIT_CYCLES    = 5

def load_file_to_s3(local_file_path, temp_file_name):
    s3 = boto3.resource('s3')
    # Save the file in S3 with a temporary naming convention.
    s3.Object(S3_BUCKET, temp_file_name).put(Body=open(local_file_path, 'rb'))
    logging.info(f'Uploaded {local_file_path} to S3')

def run_redshift_statement(sql_statement):
    """
    Generic function to handle redshift statements (DDL, SQL..),
    it retries for the maximum MAX_WAIT_CYCLES.
    Returns the result set if the statement return results.
    """
    res = client.execute_statement(
        Database=REDSHIFT_DATABASE,
        WorkgroupName=REDSHIFT_WORKGROUP,
        Sql=sql_statement
    )

    # DDL statements such as CREATE TABLE doesn't have result set.
    has_result_set = False
    done = False
    attempts = 0

    while not done and attempts < MAX_WAIT_CYCLES:

        attempts += 1
        time.sleep(1)

        desc = client.describe_statement(Id=res['Id'])
        query_status = desc['Status']

        if query_status == "FAILED":
            raise Exception('SQL query failed: ' + desc["Error"])

        elif query_status == "FINISHED":
            done = True
            has_result_set = desc['HasResultSet']
        else:
            logging.info("Current working... query status is: {} ".format(query_status))

        if not done and attempts >= MAX_WAIT_CYCLES:
            raise Exception('Maximum of ' + str(attempts) + ' attempts reached.')

        if has_result_set:
            data = client.get_statement_result(Id=res['Id'])
            return data
        
def create_redshift_table():
    create_table_ddl = """
        CREATE TABLE IF NOT EXISTS public.entry_shopee (
            id_do_pedido character varying(256) ENCODE lzo,
            status_do_pedido character varying(256) ENCODE lzo,
            status_da_devolucao___reembolso character varying(256) ENCODE lzo,
            numero_de_rastreamento character varying(256) ENCODE lzo,
            opcao_de_envio character varying(256) ENCODE lzo,
            metodo_de_envio character varying(256) ENCODE lzo,
            data_prevista_de_envio timestamp without time zone ENCODE az64,
            tempo_de_envio timestamp without time zone ENCODE az64,
            data_de_criacao_do_pedido timestamp without time zone ENCODE az64,
            hora_do_pagamento_do_pedido timestamp without time zone ENCODE az64,
            no_de_referencia_do_sku_principal character varying(256) ENCODE lzo,
            nome_do_produto character varying(256) ENCODE lzo,
            numero_de_referencia_sku character varying(256) ENCODE lzo,
            nome_da_variacao character varying(256) ENCODE lzo,
            preco_original real ENCODE raw,
            preco_acordado real ENCODE raw,
            quantidade integer ENCODE az64,
            returned_quantity integer ENCODE az64,
            subtotal_do_produto real ENCODE raw,
            desconto_do_vendedor real ENCODE raw,
            desconto_do_vendedor_1 real ENCODE raw,
            reembolso_shopee real ENCODE raw,
            peso_total_sku real ENCODE raw,
            numero_de_produtos_pedidos integer ENCODE az64,
            peso_total_do_pedido real ENCODE raw,
            codigo_do_cupom character varying(256) ENCODE lzo,
            cupom_do_vendedor real ENCODE raw,
            seller_absorbed_coin_cashback real ENCODE raw,
            cupom_shopee real ENCODE raw,
            indicador_da_leve_mais_por_menos character varying(256) ENCODE lzo,
            desconto_shopee_da_leve_mais_por_menos real ENCODE raw,
            desconto_da_leve_mais_por_menos_do_vendedor real ENCODE raw,
            compensar_moedas_shopee integer ENCODE az64,
            total_descontado_cartao_de_credito real ENCODE raw,
            valor_total real ENCODE raw,
            taxa_de_envio_pagas_pelo_comprador real ENCODE raw,
            desconto_de_frete_aproximado real ENCODE raw,
            taxa_de_envio_reversa real ENCODE raw,
            taxa_de_transacao real ENCODE raw,
            taxa_de_comissao real ENCODE raw,
            taxa_de_servico real ENCODE raw,
            total_global real ENCODE raw,
            valor_estimado_do_frete real ENCODE raw,
            nome_de_usuario__comprador_ character varying(256) ENCODE lzo,
            nome_do_destinatario character varying(256) ENCODE lzo,
            telefone character varying(256) ENCODE lzo,
            cpf_do_comprador character varying(256) ENCODE lzo,
            endereco_de_entrega character varying(256) ENCODE lzo,
            cidade character varying(256) ENCODE lzo,
            bairro character varying(256) ENCODE lzo,
            cidade_1 character varying(256) ENCODE lzo,
            uf character varying(256) ENCODE lzo,
            pais character varying(256) ENCODE lzo,
            cep integer ENCODE az64,
            observacao_do_comprador character varying(256) ENCODE lzo,
            hora_completa_do_pedido timestamp without time zone ENCODE az64,
            nota character varying(256) ENCODE lzo,
            load_timestamp timestamp without time zone ENCODE az64
        ) DISTSTYLE AUTO;
    """

    run_redshift_statement(create_table_ddl)
    logging.info('Table created successfully.')

def import_s3_file(file_name):
    """
    Loads the content of the S3 temporary file into the Redshift table.
    """
    print("file_name is: ", f"s3://{S3_BUCKET}{file_name}")
    load_data_ddl = f"""
        COPY entry_shopee
        FROM 's3://{S3_BUCKET}/{file_name}' 
        DELIMITER ','
        IGNOREHEADER as 1
        REGION 'us-east-1'
        IAM_ROLE default
        MAXERROR 1000;
    """

    run_redshift_statement(load_data_ddl)
    logging.info('Imported S3 file to Redshift.')


client = boto3.client('redshift-data', region_name='us-east-1')


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    logging.info('Process started')

    create_redshift_table()


    local_file_path = "C:/Users/nicol/OneDrive/Área de Trabalho/e-commerce-sales-pipeline/cloud/extraction/data/shopee/clean/dev/"
    filelist = os.listdir(local_file_path)
    files = [f"{local_file_path}{file}" for file in filelist]
    print("files are: ", files)


    for file in files:
        temp_file_name = f"data/shopee/clean/dev/{pathlib.Path(file).stem}.csv"
        print("Temp+file+name is:", temp_file_name)
        print("file is: ", file)

        load_file_to_s3(f"{file}", temp_file_name)
        
        import_s3_file(temp_file_name)
    logging.info('Process finished')