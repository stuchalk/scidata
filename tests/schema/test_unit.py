import json
import jsonschema
import pathlib
import pytest

from tests.utils import validate_with_schema_deps

@pytest.fixture(name="unit_schema")
def fixture__unit_schema():
    this_file = pathlib.Path(__file__)
    unit_path = "../../schema/unit.json"
    schema_file = this_file.parents[0] / pathlib.Path(unit_path)
    return json.loads(schema_file.read_text())

def test_unit_schema(context_schema, unit_schema) -> None:
    data = """
    {
        "@context": [
            "https://stuchalk.github.io/scidata/contexts/scidata_unit.jsonld",
            {"@base": "https://stuchalk.github.io/scidata/examples/unit.jsonld#"}
        ],
        "@id": "",
        "name": "Mile per hour",
        "unitsystemref": "sci:imperial",
        "quantity": "speed",
        "abbrev": "mph",
        "symbol": "mile hr-1",
        "unitinsi": {
            "@id": "unitinsi",
            "siunit": [
                {
                    "@id": "siunit/1",
                    "name": "meter",
                    "prefix": "1",
                    "power": 1
                },
                {
                    "@id": "siunit/2",
                    "name": "second",
                    "prefix": "1",
                    "power": -1
                }
            ],
            "factor": {
                "@id": "mph/to/mps/conversionFactor",
                "fromunit": "mile per hour",
                "tounit": "meter per second",
                "multiplier": 1609.34,
                "divisor": 3600,
                "exact": false
            }
        },
        "factor": {
            "@id": "mph/to/kph/conversionFactor",
            "fromunit": "mile per hour",
            "tounit": "kilometer per hour",
            "multiplier": 1.60934,
            "exact": false
        }
    }
    """
    data = json.loads(data)
    assert validate_with_schema_deps(context_schema, unit_schema, data)


def test_unit_schema_bad_name(context_schema, unit_schema) -> None:
    data = """
    {
        "@context": [
            "https://stuchalk.github.io/scidata/contexts/scidata_unit.jsonld",
            {"@base": "https://stuchalk.github.io/scidata/examples/unit.jsonld#"}
        ],
        "@id": "",
        "name": 11111111111111111
    }
    """
    data = json.loads(data)
    assert not validate_with_schema_deps(context_schema, unit_schema, data)

def test_unit_schema_no_extra_props(context_schema, unit_schema) -> None:
    data = """
    {
        "@context": [
            "https://stuchalk.github.io/scidata/contexts/scidata_unit.jsonld",
            {"@base": "https://stuchalk.github.io/scidata/examples/unit.jsonld#"}
        ],
        "@id": "",
        "CANNOT HAVE": "EXTRA ARGS"
    }
    """
    data = json.loads(data)
    assert not validate_with_schema_deps(context_schema, unit_schema, data)
