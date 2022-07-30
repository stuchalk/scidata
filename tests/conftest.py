import json
import pathlib
import pytest

@pytest.fixture(name="context_schema")
def fixture__context_schema():
    this_file = pathlib.Path(__file__)
    path = "../schema/context.json"
    schema_file = this_file.parents[0] / pathlib.Path(path)
    return json.loads(schema_file.read_text())
