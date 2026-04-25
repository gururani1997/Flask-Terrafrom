from flask import Flask, jsonify, request
from pymongo import MongoClient
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

@app.route('/', methods=['GET'])
@app.route('/api/', methods=['GET'])
@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok"}), 200

mongo_uri = os.getenv('MONGO_URI')
if mongo_uri:
    client = MongoClient(mongo_uri)
    db = client.get_database('MongoLearn')
    collection = db.get_collection('py_users')
else:
    client = None
    collection = None

@app.route('/submit', methods=['POST'])
@app.route('/api/submit', methods=['POST'])
def submit():
    if collection is None:
        return jsonify({"error": "Database not configured"}), 500
    data = request.get_json()
    name = data.get('name', '').strip()
    email = data.get('email', '').strip()
    if not name or not email:
        return jsonify({"error": "All fields are required"}), 400
    try:
        collection.insert_one({"name": name, "email": email})
        return jsonify({"message": "Data submitted successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=False)