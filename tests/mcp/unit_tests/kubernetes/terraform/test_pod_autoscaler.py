"""
Terraform external provider just handles strings in maps, so tests need to consider this
"""
from sys import path, stderr

try:
    path.insert(1, '../../../../test_fixtures/python_validator')
    from python_validator import python_validator
except Exception as e:
    print(e, file=stderr)


@python_validator
def test_pod_autoscaler(query):

    expected_data = {
        "kind" : "Deployment",
        "name" : "MyApp"
    }

    if query == expected_data:
        return {"result": "pass"}
    else:
        return {"result" : "fail",
                "expected" : "{}".format(expected_data),
                "received" : "{}".format(query)}


if __name__ == '__main__':
    test_pod_autoscaler()
