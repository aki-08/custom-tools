from functools import reduce
import logging

logging.basicConfig(filename='c3.log', filemode='w', format='%(name)s - %(levelname)s - %(message)s')

def get_value(obj, keys):
    """
    This function is used to extract the value inside the key
    Usage ==> challenge3(obj, "a/b/c")
    :param obj: any dictionary
    :type obj: dict
    :param keys: keys separated by /
    :type keys: str
    :return: if valid key it will return value of the key else None
    """
    try:
        return reduce(lambda val, key: val.get(key), keys.split("/"), obj)
    except Exception as e:
        logging.error(e, exc_info=True)


def get_value_a2(obj, *keys):
    """
    This function is used to extract the value inside the key
    Usage ==> challenge3_a2(obj, "a","b","c")
    :param obj: any dictionary
    :type obj: dict
    :param `*keys`: The variable arguments are used for providing the keys as string
    :return: if valid key it will return value of the key else None
    """
    try:
        return reduce(lambda val, key: val.get(key), keys, obj)
    except Exception as e:
        logging.error(e, exc_info=True)
