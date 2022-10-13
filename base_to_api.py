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


def calc_mean(val):
    values = []
    for key, value in val.items():
        values.append(float(key)*value)
    return sum(values)/len(values)


def request(name, source, destination, type, time_range, target_bandwidth="9999999999"):
    url = "http://monipe-central.rnp.br/esmond/perfsonar/archive/?"
    hearder = {"pscheduler-test-type": type, "source": source, "destination": destination,
               "bw-target-bandwidth": target_bandwidth, "time-range": time_range}
    response = requests.get(url, params=hearder)
    json_data = response.json()
    if (response.status_code == 200):
        datas = []
        for obj in json_data:
            url_obj = obj["url"]
            get_url_base_obj = request_by_metadata_key(url_obj, type)
            if (not isinstance(get_url_base_obj, int)):
                url_base = get_url_base_obj["base-uri"]
                f = open(name+" esmond data " +
                         today.strftime("%m-%d-%Y")+".csv", "w")
                data = get_data(url_base, time_range)
                datas.insert(0, data)
            else:
                return "Error " + response.status_code
        teste = []
        for i in range(len(datas)):
            cont = 0
            soma = 0
            anterior = None
            for obj in datas[i]:
                data = datetime.fromtimestamp(int(obj["ts"]))
                dia = str(data).split()[0][-2::]
                if (str(data).split()[0][-5::]) not in teste:
                    teste.append(str(data).split()[0][-5::])
                if dia == anterior or anterior is None:
                    soma += obj["val"]
                    cont += 1
                    f.write(datetime.fromtimestamp(int(obj["ts"])).strftime(
                        '%Y-%m-%d %H:%M:%S')+", "+str(obj["val"])+"\n")
                else:
                    media = soma/cont
                    ciclos = 6-cont
                    for i in range(ciclos):
                        cont += 1
                        f.write(datetime.fromtimestamp(
                            int(obj["ts"]-86400)).strftime('%Y-%m-%d %H:%M:%S')+", "+str(media)+"\n")
                    soma = 0
                if cont == 6:
                    cont = 0
                    anterior = None
                else:
                    anterior = dia
        print(len(teste)*6)
        for i in teste:
            print(i)
        f.close()
    else:
        return "Error: " + response.status_code


def request_atraso(name, source, destination, type, time_range, label):
    url = "http://monipe-central.rnp.br/esmond/perfsonar/archive/?"
    hearder = {"pscheduler-test-type": type, "source": source,
               "destination": destination, "time-range": time_range}
    response = requests.get(url, params=hearder)
    json_data = response.json()
    values = []
    if (response.status_code == 200):
        print("Ok")
        bases = []
        for obj in json_data:
            types_list = obj['event-types']
            for obj_types in types_list:
                if obj_types.get('event-type') == label:
                    bases.append(obj_types.get('base-uri'))
                    break
        with open(name+" esmond data " + today.strftime("%m-%d-%Y")+".csv", "w") as f:
            for link in bases:
                values = get_data(link, time_range)
                i = 1
                items = []
                tempos = []
                for value in values:
                    if i == 1:
                        tempos.append(value['ts'])
                    items.append(calc_mean(value['val']))
                    if len(items) == 15:
                        dif = value['ts'] - tempos[0]
                        if dif > 1000:
                            f.write(
                                f"{tempos[0]}, {value['ts']}, {sum(items)/len(items)} ##\n")
                        else:
                            f.write(
                                f"{tempos[0]}, {value['ts']}, {sum(items)/len(items)}\n")
                        tempos = []
                        items = []
                        i = 1
                        continue
                    i += 1


def request_perda(name, source, destination, type, time_range, label):
    url = "http://monipe-central.rnp.br/esmond/perfsonar/archive/?"
    hearder = {"pscheduler-test-type": type, "source": source,
               "destination": destination, "time-range": time_range}
    response = requests.get(url, params=hearder)
    json_data = response.json()
    values = []
    if (response.status_code == 200):
        print("Ok")
        bases = []
        for obj in json_data:
            types_list = obj['event-types']
            for obj_types in types_list:
                if obj_types.get('event-type') == label:
                    bases.append(obj_types.get('base-uri'))
                    break
        with open(name+" esmond data " + today.strftime("%m-%d-%Y")+".csv", "w") as f:
            for link in bases:
                values = get_data(link, time_range)
                tempos = [i['ts'] for i in values]
                tempos.sort()
                for value in values:
                    f.write(f"{value['ts']}, {value['val']}\n")


# request("cubic", "monipe-ce-banda.rnp.br", "monipe-sp-banda.rnp.br", "throughput", "15552000") # 6 meses
# request("bbr", "monipe-ce-banda.rnp.br", "monipe-sp-banda.rnp.br", "throughput", "15552000", "10000000000") # 6 meses
request_atraso("atraso", "monipe-ce-atraso.rnp.br",
               "monipe-sp-atraso.rnp.br", "latencybg", "7776000", "histogram-owdelay")  # 3 meses

request_perda("perda", "monipe-ce-atraso.rnp.br",
              "monipe-sp-atraso.rnp.br", "rtt", "7776000", "packet-count-lost-bidir")  # 3 meses
