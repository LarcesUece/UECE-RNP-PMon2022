import requests
from datetime import date, datetime
from calendar import timegm

today = date.today()

base = "http://monipe-central.rnp.br"

def get_data(url_slice, time_range):
    url = base+url_slice
    header = {"time-range": time_range}
    response = requests.get(url, params=header)
    json_data = response.json()
    return json_data

def request_by_metadata_key(url, type):
    url_ = url
    response = requests.get(url_)
    json_data = response.json()
    if (response.status_code == 200):
        for obj in json_data["event-types"]:
            if obj["event-type"] == type:
                return obj
    else: 
        return response.status_code

def request(name, source, destination, type, time_range, target_bandwidth="9999999999"):
    url = "http://monipe-central.rnp.br/esmond/perfsonar/archive/?"
    hearder = {"pscheduler-test-type": type, "source": source, "destination": destination, "bw-target-bandwidth": target_bandwidth, "time-range": time_range}
    response = requests.get(url, params=hearder)
    json_data = response.json()
    if (response.status_code == 200):
        datas = []
        for obj in json_data:
            url_obj = obj["url"]
            get_url_base_obj = request_by_metadata_key(url_obj, type)
            if (not isinstance(get_url_base_obj, int)):
                url_base = get_url_base_obj["base-uri"]
                f = open(name+" esmond data "+today.strftime("%m-%d-%Y")+".csv", "w")
                f2 = open(name+" dados sem tratamendo "+today.strftime("%m-%d-%Y")+".csv", "w")
                data = get_data(url_base, time_range)
                datas.insert(0, data)
            else:
                return "Error " + response.status_code
        cont = 0
        soma = 0
        anterior = None
        teste = {}
        dados = []
        for i in range(len(datas)):
            dados += datas[i]
        for obj in dados:
            data = datetime.fromtimestamp(int(obj["ts"]))
            f2.write(datetime.fromtimestamp(int(obj["ts"])).strftime('%Y-%m-%d %H:%M:%S')+", "+str(obj["val"])+"\n")
            dia = str(data).split()[0][-2::]
            if str(data).split()[0][-5::] not in teste.keys():
                teste.setdefault(str(data).split()[0][-5::], 0)
            else:
                teste[str(data).split()[0][-5::]] += 1
            if dia == anterior or anterior is None:
                ultimo = obj["ts"]
                soma += obj["val"]
                cont += 1
                if cont > 6:
                    anterior = dia
                    ultimo = obj["ts"]
                    continue
                f.write(datetime.fromtimestamp(int(obj["ts"])).strftime('%Y-%m-%d %H:%M:%S')+", "+str(obj["val"])+"\n")
            else:
                media = soma/cont
                ciclos = 6-cont
                for i in range(ciclos):
                    cont += 1
                    f.write(datetime.fromtimestamp(int(ultimo)).strftime('%Y-%m-%d %H:%M:%S')+", "+str(media)+"\n")
                soma = 0
                soma += obj["val"]
                f.write(datetime.fromtimestamp(int(obj["ts"])).strftime('%Y-%m-%d %H:%M:%S')+", "+str(obj["val"])+"\n")
                cont = 1
            anterior = dia
            ultimo = obj["ts"]
        ciclos = 6-cont
        for i in range(ciclos):
            f.write(datetime.fromtimestamp(int(obj["ts"])).strftime('%Y-%m-%d %H:%M:%S')+", "+str(obj["val"])+"\n")
        f.close()
        f2.close()
        print(len(teste)*6)
        print(len(teste.keys())*6)
    else:
        return "Error: " + response.status_code
    
request("cubic", "monipe-ce-banda.rnp.br", "monipe-sp-banda.rnp.br", "throughput", "15552000") # 6 meses
request("bbr", "monipe-ce-banda.rnp.br", "monipe-sp-banda.rnp.br", "throughput", "15552000", "10000000000") # 6 meses