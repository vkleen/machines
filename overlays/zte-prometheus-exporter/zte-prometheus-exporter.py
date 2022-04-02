#!@python@/bin/python

import requests
import xml.etree.ElementTree as ET
from getpass import getpass
from hashlib import sha256

from time import sleep

import re

import json

from os import environ
import sys

from http.server import BaseHTTPRequestHandler, HTTPServer

from urllib.parse import urlparse

from pytimeparse.timeparse import timeparse

from textwrap import dedent


def _format_prom_attrs(**attrs):
    if not attrs:
        return ''

    return '{' + ','.join(map(lambda k: f'{k}="{attrs[k]}"', attrs)) + '}'

def _format_prom_metrics(metricName, metricType, metrics, metricHelp=''):
    metricStr = dedent(f'''
      # HELP {metricName} {metricHelp}
      # TYPE {metricName} {metricType}
    ''').lstrip()
    for (attrs, val) in metrics:
        attrs_str = _format_prom_attrs(**attrs)
        metricStr += dedent(f'''
            {metricName}{attrs_str} {val}
        ''').lstrip()
    return metricStr


class ZTEMetrics:
    _instance = None

    @classmethod
    def instance(cls):
        if cls._instance is None:
            cls._instance = cls.__new__(cls)
            cls._instance.base_url = environ.get('ZTE_BASEURL')
            cls._instance.username = environ.get('ZTE_USERNAME')
            cls._instance.password = environ.get('ZTE_PASSWORD')
            cls._instance.attrs = None
        return cls._instance
    

    def __init__(self):
        raise RuntimeError('Call instance() instead')

    _error_pattern = re.compile('^IF_ERROR(PARAM|TYPE|STR|ID)$')
    _obj_pattern = re.compile('^(?:OBJ_(.+)_ID)|(?:ID_(WAN_COMFIG))$')
    def update(self):
        attrs = dict()

        with requests.Session() as session:
            session.get(self.base_url)

            tok_req = session.get(f'{self.base_url}/function_module/login_module/login_page/logintoken_lua.lua')
            tok_tree = ET.fromstring(tok_req.text)
            login_token = tok_tree.text

            password_hash = sha256((self.password + login_token).encode('utf-8')).hexdigest()

            session.post(self.base_url, data = { 'Username': self.username, 'Password': password_hash, 'action': 'login' })

            dev_req = session.get(f'{self.base_url}/common_page/ManagReg_lua.lua')
            sntp_req = session.get(f'{self.base_url}/getpage.lua?pid=1005&nextpage=Internet_sntp_lua.lua')
            session.get(f'{self.base_url}/getpage.lua?pid=123&nextpage=Internet_AdminInternetStatus_DSL_t.lp')
            dsl_req = session.get(f'{self.base_url}/common_page/internet_dsl_interface_lua.lua')
            ppp_req = session.get(f'{self.base_url}/common_page/Internet_Internet_lua.lua?TypeUplink=1&pageType=1')
            session.get(f'{self.base_url}/getpage.lua?pid=123&nextpage=Localnet_LocalnetStatusAd_t.lp')
            lan_req = session.get(f'{self.base_url}/common_page/lanStatus_lua.lua')
            dhcp_req = session.get(f'{self.base_url}/common_page/Localnet_LanMgrIpv4_DHCPHostInfo_lua.lua')

            for req in [dev_req, sntp_req, dsl_req, ppp_req, lan_req, dhcp_req]:
                xml = ET.fromstring(req.text)
                for child in xml:
                    if self._error_pattern.match(child.tag):
                        continue
                    obj_tag = self._obj_pattern.match(child.tag)
                    if not obj_tag:
                        continue
                    obj_type = obj_tag.group(1) or obj_tag.group(2)

                    for instance in child.findall('Instance'):
                        instance_dict = dict()
                        name = None
                        value = None
                        for child in instance:
                            match child.tag:
                                case 'ParaName':
                                    name = child.text
                                case 'ParaValue':
                                    value = child.text
                                case _:
                                    pass
                            if not name is None and not value is None:
                                instance_dict[name] = value
                                name = None
                                value = None

                        if obj_type not in attrs:
                            attrs[obj_type] = dict()
                        attrs[obj_type][instance_dict['_InstID']] = instance_dict

        self.attrs = attrs

    def json_text(self):
        return json.dumps(self.attrs)

    _link_pattern = re.compile('^IGD\.WD1\.LINE([0-9]+)$')
    _eth_pattern = re.compile('^IGD\.LD1\.ETH([0-9]+)$')
    def prometheus(self):
        metrics = ''

        uptime_seconds = timeparse(self.attrs['SYSTEMYIME']['IGD']['systemTime'])
        metrics += _format_prom_metrics('uptime_seconds', 'gauge', [({}, uptime_seconds)], 'Seconds device has been running')

        link_metrics = dict()
        for link in self.attrs['DSLINTERFACE']:
            link_match = self._link_pattern.match(link)
            link_number = link_match.group(1)

            if 'crc_errors_count' not in link_metrics:
                link_metrics['crc_errors_count'] = {'type': 'counter', 'metrics': []}
            link_metrics['crc_errors_count']['metrics'] += [({"direction": "up", "link": link_number}, int(self.attrs['DSLINTERFACE'][link]['UpCrc_errors']))]
            link_metrics['crc_errors_count']['metrics'] += [({"direction": "down", "link": link_number}, int(self.attrs['DSLINTERFACE'][link]['DownCrc_errors']))]

            if 'noise_margin_db' not in link_metrics:
                link_metrics['noise_margin_db'] = {'type': 'gauge', 'metrics': []}
            link_metrics['noise_margin_db']['metrics'] += [({"direction": "up", "link": link_number}, int(self.attrs['DSLINTERFACE'][link]['Upstream_noise_margin']))]
            link_metrics['noise_margin_db']['metrics'] += [({"direction": "down", "link": link_number}, int(self.attrs['DSLINTERFACE'][link]['Downstream_noise_margin']))]

            if 'attenuation_db' not in link_metrics:
                link_metrics['attenuation_db'] = {'type': 'gauge', 'metrics': []}
            link_metrics['attenuation_db']['metrics'] += [({"direction": "up", "link": link_number}, int(self.attrs['DSLINTERFACE'][link]['Upstream_attenuation']))]
            link_metrics['attenuation_db']['metrics'] += [({"direction": "down", "link": link_number}, int(self.attrs['DSLINTERFACE'][link]['Downstream_attenuation']))]

            if 'max_rate_kbps' not in link_metrics:
                link_metrics['max_rate_kbps'] = {'type': 'gauge', 'metrics': []}
            link_metrics['max_rate_kbps']['metrics'] += [({"direction": "up", "link": link_number}, int(self.attrs['DSLINTERFACE'][link]['Upstream_max_rate']))]
            link_metrics['max_rate_kbps']['metrics'] += [({"direction": "down", "link": link_number}, int(self.attrs['DSLINTERFACE'][link]['Downstream_max_rate']))]

            if 'current_rate_kbps' not in link_metrics:
                link_metrics['current_rate_kbps'] = {'type': 'gauge', 'metrics': []}
            link_metrics['current_rate_kbps']['metrics'] += [({"direction": "up", "link": link_number}, int(self.attrs['DSLINTERFACE'][link]['Upstream_current_rate']))]
            link_metrics['current_rate_kbps']['metrics'] += [({"direction": "down", "link": link_number}, int(self.attrs['DSLINTERFACE'][link]['Downstream_current_rate']))]

            if 'dsl_uptime_seconds' not in link_metrics:
                link_metrics['dsl_uptime_seconds'] = {'type': 'gauge', 'metrics': []}
            link_metrics['dsl_uptime_seconds']['metrics'] += [({"link": link_number}, int(self.attrs['DSLINTERFACE'][link]['Showtime_start']))]
        if link_metrics:
            for metric_name in link_metrics:
                metrics += _format_prom_metrics(f'dsl_{metric_name}', link_metrics[metric_name]['type'], link_metrics[metric_name]['metrics'])

        eth_metrics = dict()
        for link in self.attrs['ETH']:
            link_match = self._eth_pattern.match(link)
            link_number = link_match.group(1)

            if 'received_bytes' not in eth_metrics:
                eth_metrics['received_bytes'] = {'type': 'counter', 'metrics': []}
            eth_metrics['received_bytes']['metrics'] += [({"interface": link_number}, int(self.attrs['ETH'][link]['BytesReceived']))]
            if 'sent_bytes' not in eth_metrics:
                eth_metrics['sent_bytes'] = {'type': 'counter', 'metrics': []}
            eth_metrics['sent_bytes']['metrics'] += [({"interface": link_number}, int(self.attrs['ETH'][link]['BytesSent']))]
        if eth_metrics:
            for metric_name in eth_metrics:
                metrics += _format_prom_metrics(f'eth_{metric_name}', eth_metrics[metric_name]['type'], eth_metrics[metric_name]['metrics'])

        return metrics.encode('utf-8')

class ZTEMetricsServer(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass

    def do_GET(self):
        zte_metrics = ZTEMetrics.instance()
        zte_metrics.update()

        url = urlparse(self.path)

        match url.path:
            case '/metrics.json':
                self.send_response(200)
                self.send_header("Content-type", "application/json")
                self.end_headers()

                self.wfile.write(zte_metrics.json_text().encode('utf-8'))
            case '/metrics':
                self.send_response(200)
                self.send_header("Content-type", "text/plain")
                self.end_headers()
                
                self.wfile.write(zte_metrics.prometheus())
            case _:
                self.send_response(404)
                self.end_headers()


def main():
    webServer = HTTPServer((str(environ.get('ZTE_HOSTNAME')), int(environ.get('ZTE_PORT'))), ZTEMetricsServer)

    webServer.serve_forever()

if __name__ == "__main__":
    sys.exit(main())
