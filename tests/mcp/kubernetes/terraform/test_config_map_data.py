from sys import path, stderr

try:
    path.insert(1, '../../../test_fixtures/python_validator')
    from python_validator import python_validator
except Exception as e:
    print(e, file=stderr)

@python_validator
def test_config_map_data(query):
    """
    Tests the configuration of `data` mapping. `data ` contains configuration
    data, mapped like the following:
    data = {
        api_host             = "myhost:443"
        db_host              = "dbhost:5432"
        "my_config_file.yml" = "${file("${path.module}/my_config_file.yml")}"
    }

    """

    expected_data = {
        "mosquitto.conf" : "log_dest stdout\nlog_type all\nlog_timestamp true\nlistener 9001\n",
        "test" : "test"
    }

    if query == expected_data:
        return {"result": "pass"}
    else:
        return {"result" : "fail, expected data = {}, received data = {}".format(expected_data, query)}



if __name__ == '__main__':
    test_config_map_data()
