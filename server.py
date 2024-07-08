from flask import Flask, jsonify, request
from flask_cors import CORS
from dotenv import load_dotenv
import os
import psycopg

# Load environment variables from a .env file
load_dotenv()

# Initialize a Flask application
app = Flask(__name__)

# Enable Cross-Origin Resource Sharing (CORS) for the Flask application
CORS(app)

def get_db_connection():
    """
    Establish a connection to the PostgreSQL database using psycopg.
    Database connection parameters are retrieved from environment variables.

    Returns:
        psycopg.Connection: Connection object for interacting with the PostgreSQL database.
    """
    conn = psycopg.connect(
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT"),
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD")
    )
    return conn

@app.route('/home', methods=['GET'])
def home():
    """
    Endpoint to fetch route information between two points.
    Expects two query parameters: 'point_1' and 'point_2'.

    Returns:
        JSON response containing route information or an error message if parameters are missing.
    """
    # Retrieve query parameters
    point_1 = request.args.get('point_1')
    point_2 = request.args.get('point_2')
    
    # Validate query parameters
    if not point_1 or not point_2:
        return jsonify({'error': 'Missing parameters'}), 400
    
    # Establish database connection
    conn = get_db_connection()
    with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
        # SQL queries to fetch route information
        queries = [
            "SELECT * FROM get_direct_routes_geojson(%s, %s);",
            "SELECT * FROM get_one_transfer_routes_geojson(%s, %s);",
            "SELECT * FROM get_two_transfer_routes_geojson(%s, %s);"
        ]
        # Function names to be used to compute each type of trip
        function_names = [
            "get_direct_routes_geojson",
            "get_one_transfer_routes_geojson",
            "get_two_transfer_routes_geojson"
        ]
        # Initialize index and result list
        idx = -1
        rows = []
        # Execute queries until results are found or all queries are exhausted
        while not rows and idx < len(queries) - 1:
            idx += 1
            cur.execute(queries[idx], (point_1, point_2))
            results = cur.fetchall()
            rows = [obj[function_names[idx]] for obj in results]
    
    # Close the database connection
    conn.close()
    
    # Return the route information as a JSON response
    return jsonify(rows)

if __name__ == '__main__':
    # Run the Flask application in debug mode, accessible on all network interfaces
    app.run(debug=True, host='0.0.0.0', port=5000)
