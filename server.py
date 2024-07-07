from flask import Flask, jsonify, request
from flask_cors import CORS
from dotenv import load_dotenv
import os
import psycopg

# Load environment variables from .env file
load_dotenv()

app = Flask(__name__)
CORS(app)

def get_db_connection():
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
    point_1 = request.args.get('point_1')
    point_2 = request.args.get('point_2')
    
    if not point_1 or not point_2:
        return jsonify({'error': 'Missing parameters'}), 400
    
    conn = get_db_connection()
    with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
        queries = [
            "SELECT * FROM get_direct_routes_geojson(%s, %s);",
            "SELECT * FROM get_one_transfer_routes_geojson(%s, %s);",
            "SELECT * FROM get_two_transfer_routes_geojson(%s, %s);"
        ]
        function_names = [
            "get_direct_routes_geojson",
            "get_one_transfer_routes_geojson",
            "get_two_transfer_routes_geojson"
        ]
        idx = -1
        rows = []
        while not rows and idx < len(queries) - 1:
            idx += 1
            cur.execute(queries[idx], (point_1, point_2))
            results = cur.fetchall()
            rows = [obj[function_names[idx]] for obj in results]
    
    conn.close()
    return jsonify(rows)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
