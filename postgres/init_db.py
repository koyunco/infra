import psycopg2
from psycopg2 import sql
import logging
 
 # Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Database connection parameters
db_params = {
    'dbname': 'mertpolat',
    'user': 'mertpolat',
    'password': 'Spain2004',
    'host': '127.0.0.1',
    'port': '5432'
}
 
# Path to the SQL file
sql_file_path = 'datamodel.sql'
 
def execute_sql_file(cursor, file_path):
    with open(file_path, 'r') as file:
        sql_commands = file.read()
        cursor.execute(sql_commands)
 
def main():
    try:
        # Connect to the PostgreSQL database
        logging.info("Connecting to the database with provided credentials.")
        conn = psycopg2.connect(**db_params)
        cursor = conn.cursor()
 
        # Execute the SQL file
        execute_sql_file(cursor, sql_file_path)
 
        # Commit the transaction
        conn.commit()

        logging.info("Database tables created successfully.")
 
    except Exception as e:
        print(f"An error occurred: {e}")
        if conn:
            conn.rollback()
 
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()
 
if __name__ == "__main__":
    main()