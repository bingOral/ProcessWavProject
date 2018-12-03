from flask import Flask, request, Response  
import json
 
app = Flask(__name__)


@app.route('/callback_save_results', methods=['POST'])
def my_json():
	print request.headers
	print request.json

	asr_res = ""
	reference = ""
	try:
		asr_res = (request.json)["channels"]["channel1"]["transcript"][0]["text"]
		reference = (request.json)["reference"]
	except:
		asr_res = ""
		reference = ""

	f = open(r'call_nuance_english_asr.txt','w+')
	f.write(reference + '|' + asr_res)
	return asr_res

if __name__ == '__main__':
	app.run(debug = True)
