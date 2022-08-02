import json
import pathlib
import pytest

@pytest.fixture(name="context_schema")
def fixture__context_schema():
    this_file = pathlib.Path(__file__)
    path = "../schema/context.json"
    schema_file = this_file.parents[0] / pathlib.Path(path)
    return json.loads(schema_file.read_text())


@pytest.fixture(name="unit_schema")
def fixture__unit_schema():
    this_file = pathlib.Path(__file__)
    unit_path = "../schema/unit.json"
    schema_file = this_file.parents[0] / pathlib.Path(unit_path)
    return json.loads(schema_file.read_text())


@pytest.fixture(name="value_schema")
def fixture__value_schema():
    this_file = pathlib.Path(__file__)
    value_path = "../schema/value.json"
    schema_file = this_file.parents[0] / pathlib.Path(value_path)
    return json.loads(schema_file.read_text())
