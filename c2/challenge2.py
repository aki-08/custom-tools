import requests
import json
import logging
from functools import reduce

logging.basicConfig(filename='c2.log', filemode='w', format='%(name)s - %(levelname)s - %(message)s')

imds_url = "http://169.254.169.254/latest/"
meta = "meta-data"
api_url = imds_url + "/api/token"
token_ttl_seconds = 21600
token_header = "X-aws-ec2-metadata-token"
token_header_ttl = "X-aws-ec2-metadata-token-ttl-seconds"
metadata = {meta: {}}


def meta_data_retriever():
    """
    This function is used to fetch the metadata of an instance from aws imds v2 service
    Usage ==> meta_data_retriever()
    :return: json formatted aws instance metadata
    """
    try:
        api_token = requests.put(api_url, headers={token_header_ttl: str(token_ttl_seconds)}, timeout=5.0)
        if api_token.status_code != 200:
            api_token.raise_for_status()
        token = api_token.text
        json_formatter(f'{imds_url}{meta}', metadata[meta], token)
        return json.dumps(metadata)
    except Exception as e:
        logging.error(e, exc_info=True)


def json_formatter(metaurl, outjson, token):
    """
    This function is called by the meta_data_retriever function in order to fill the metadata in the metadata dict
    Usage ==> json_formatter("http://169.254.169.254/latest/meta-data", metadata["meta-data"], "o2kBLbktGE/DnRc0/1cWQolTu2hl/PkrDDoXyQKL6ZE=")
    :param metaurl: aws imds url
    :type metaurl: str
    :param outjson: dict with a key
    :type outjson: dict
    :param token: X-aws-ec2-metadata-token token to fetch the metadata
    :type token: str
    """
    try:
        response = requests.get(metaurl, headers={token_header: token})
        if response.status_code == 404:
            return

        for branch in response.text.split('\n'):
            if not branch:
                continue
            childurl = f'{metaurl}/{branch}'
            if branch.endswith('/'):
                urlpath = branch.split('/')[-2]
                outjson[urlpath] = {}
                json_formatter(childurl, outjson[urlpath], token)

            else:
                response = requests.get(childurl, headers={token_header: token})
                if response.status_code != 404:
                    try:
                        outjson[branch] = json.loads(response.text)
                    except ValueError:
                        outjson[branch] = response.text
                else:
                    outjson[branch] = None
    except Exception as e:
        logging.error(e, exc_info=True)


def specific_meta_info(metakey):
    """
    This function is used to get the value of a particular key of ec2 instance metadata
    Usage ==> specific_meta_info("meta-data/ami-id")
    :param metakey: keys separated by /
    :type metakey: str
    :return: json formatted aws metadata of specific key
    """
    try:
        opmeta = json.loads(meta_data_retriever())
        return json.dumps(reduce(lambda val, key: val.get(key), metakey.split("/"), opmeta))
    except Exception as e:
        logging.error(e, exc_info=True)
