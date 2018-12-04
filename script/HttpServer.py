from flask import Flask, request, Response
from elasticsearch import Elasticsearch
import json
 
app = Flask(__name__)
es = Elasticsearch()
index = 'callserv_call_nuance_en'

@app.route('/result', methods=['POST'])
def my_json():
	print request.json
	asr_res = "@"
	reference = (request.json)["reference"]

	try:
		asr_res = (request.json)["channels"]["channel1"]["transcript"][0]["text"]
		
	except:
		asr_res = "@"

	#query
	q_res = es.search(index=index, body={"query": {"match_all": { "_id" : "reference"}}})
	wavname =  q_res['_source']['wavname']
	
	#insert
	doc = {
	    'wavname': wavname,
	    'reference': reference,
	    'text': asr_res
	}

	s_res = es.index(index=index, doc_type='data', id=reference, body=doc)
	print (s_res['result'])

	return s_res['result']

if __name__ == '__main__':
	app.run(debug = True, host = '0.0.0.0', port = '6000')
