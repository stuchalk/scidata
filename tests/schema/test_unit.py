import json
import jsonschema
import pathlib
import pytest

from tests.utils import validate_with_schema_deps


@pytest.fixture(name="unit_jsonld")
def fixture__unit_jsonld():
    this_file = pathlib.Path(__file__)
    path = "../../examples/sections/unit.jsonld"
    data_file = this_file.parents[0] / pathlib.Path(path)
    return json.loads(data_file.read_text())


def test_unit_schema(context_schema, unit_schema, unit_jsonld) -> None:
    assert validate_with_schema_deps(context_schema, unit_schema, unit_jsonld)


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
