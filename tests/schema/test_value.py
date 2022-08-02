import json
import jsonschema
import pathlib
import pytest

from tests.utils import validate_with_schema_deps


@pytest.fixture(name="value_jsonld")
def fixture__value_jsonld():
    this_file = pathlib.Path(__file__)
    path = "../../examples/sections/value.jsonld"
    data_file = this_file.parents[0] / pathlib.Path(path)
    return json.loads(data_file.read_text())


def test_value_schema(context_schema, unit_schema, value_schema, value_jsonld) -> None:
    assert validate_with_schema_deps(context_schema, value_schema, value_jsonld, schema_deps_list=[unit_schema])


def test_value_schema_bad_name(context_schema, unit_schema, value_schema) -> None:
    data = """
    {
        "@context": [
            "https://stuchalk.github.io/scidata/contexts/scidata_value.jsonld",
            "https://stuchalk.github.io/scidata/contexts/scidata_unit.jsonld",
            {"qudt": "http://www.qudt.org/qudt/owl/1.0.0/unit.owl#"},
            {"@base": "https://stuchalk.github.io/scidata/examples/value.jsonld#"}
        ],
        "@id": "",
        "numericvalue": {
            "@id": "numeric/1",
            "datatype": "decimal",
            "number": 12.0107,
            "error": "BAD VALUE",
            "sigfigs": 5,
            "unit": "unit/amu"
        }
    }
    """
    data = json.loads(data)
    assert not validate_with_schema_deps(context_schema, value_schema, data, schema_deps_list=[unit_schema])

def test_value_schema_no_extra_props(context_schema, unit_schema, value_schema) -> None:
    data = """
    {
        "@context": [
            "https://stuchalk.github.io/scidata/contexts/scidata_value.jsonld",
            "https://stuchalk.github.io/scidata/contexts/scidata_unit.jsonld",
            {"qudt": "http://www.qudt.org/qudt/owl/1.0.0/unit.owl#"},
            {"@base": "https://stuchalk.github.io/scidata/examples/value.jsonld#"}
        ],
        "@id": "",
        "numericvalue": {
            "@id": "numeric/1",
            "datatype": "decimal",
            "number": 12.0107,
            "error": 8.0E-4,
            "sigfigs": 5,
            "unit": "unit/amu"
        },
        "CANNOT HAVE": "EXTRA ARGS"
    }
    """
    data = json.loads(data)
    assert not validate_with_schema_deps(context_schema, value_schema, data, schema_deps_list=[unit_schema])
