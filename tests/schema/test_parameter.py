import json
import jsonschema
import pathlib
import pytest

from tests.utils import validate_with_schema_deps


@pytest.fixture(name="parameter_jsonld")
def fixture__parameter_jsonld():
    this_file = pathlib.Path(__file__)
    path = "../../examples/sections/parameter.jsonld"
    data_file = this_file.parents[0] / pathlib.Path(path)
    return json.loads(data_file.read_text())


@pytest.fixture(name="parameter2_jsonld")
def fixture__parameter2_jsonld():
    this_file = pathlib.Path(__file__)
    path = "../../examples/sections/parameter2.jsonld"
    data_file = this_file.parents[0] / pathlib.Path(path)
    return json.loads(data_file.read_text())


@pytest.fixture(name="parameter_json_jsonld")
def fixture__parameter_json_jsonld():
    this_file = pathlib.Path(__file__)
    path = "../../examples/sections/parameter_json.jsonld"
    data_file = this_file.parents[0] / pathlib.Path(path)
    return json.loads(data_file.read_text())


@pytest.fixture(name="schema_deps")
def fixture__schema_deps(unit_schema, value_schema):
    return [unit_schema, value_schema]


def test_parameter_schema(context_schema, schema_deps, parameter_schema, parameter_jsonld) -> None:
    assert validate_with_schema_deps(
        context_schema,
        parameter_schema,
        parameter_jsonld,
        schema_deps_list=schema_deps
    )


def test_parameter2_schema(context_schema, schema_deps, parameter_schema, parameter2_jsonld) -> None:
    assert validate_with_schema_deps(
        context_schema,
        parameter_schema,
        parameter2_jsonld,
        schema_deps_list=schema_deps
    )


def test_parameter_json_schema(context_schema, schema_deps, parameter_schema, parameter_json_jsonld) -> None:
    assert validate_with_schema_deps(
        context_schema,
        parameter_schema,
        parameter_json_jsonld,
        schema_deps_list=schema_deps
    )



def test_parameter_schema_bad_name(context_schema, schema_deps, parameter_schema) -> None:
    data = """
    {
        "@context": [
            "https://stuchalk.github.io/scidata/contexts/scidata_parameter.jsonld",
            {"@base": "https://stuchalk.github.io/scidata/examples/parameter.jsonld#"}
        ],
        "@id": "",
        "scope": 11111111111111111111,
        "quantity": "magnetic field strength",
        "property": "Anisotropic NMR Shielding",
        "value": {
            "@id": "value",
            "number": "3.2",
            "unitstr": "ppm_Hz"
        }
    }
    """
    data = json.loads(data)
    assert not validate_with_schema_deps(
        context_schema,
        parameter_schema,
        data,
        schema_deps_list=schema_deps
    )

def test_parameter_schema_no_extra_props(context_schema, schema_deps, parameter_schema) -> None:
    data = """
    {
        "@context": [
            "https://stuchalk.github.io/scidata/contexts/scidata_parameter.jsonld",
            {"@base": "https://stuchalk.github.io/scidata/examples/parameter.jsonld#"}
        ],
        "@id": "",
        "scope": "molecule/1",
        "quantity": "magnetic field strength",
        "property": "Anisotropic NMR Shielding",
        "value": {
            "@id": "value",
            "number": "3.2",
            "unitstr": "ppm_Hz"
        },
        "CANNOT HAVE": "EXTRA ARGS"
    }
    """
    data = json.loads(data)
    assert not validate_with_schema_deps(
        context_schema,
        parameter_schema,
        data,
        schema_deps_list=schema_deps
    )
