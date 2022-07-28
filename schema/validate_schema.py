import argparse
import json
import jsonschema

def validate_schema_with_deps(
    base_schema: str,
    schema_deps_list: list,
    schema: str,
    data: str
) -> (bool, str):
    """
    Validate data with schema with local schema dependencies.
    Base schema is the first schema in this dependency list
    and then the schema_deps_list is the chained list of other
    schema dependencies to build up to the final schema used to
    validate data.
    """
    # Create the full chain list of schemas for the $ref resolver
    schema_store = {}
    schemas_full_list = [base] + schema_deps_list + [schema]
    for schema_json in schemas_full_list:
        schema_id = schema_json.get("$id")
        schema_store[schema_id] = schema_json

    # Prepare validator that contains the entire schema chain
    resolver = jsonschema.RefResolver.from_schema(base, store=schema_store)
    validator = jsonschema.Draft7Validator(schema, resolver=resolver)

    # Validate JSON data against schema
    try:
        validator.validate(data)
    except jsonschema.exceptions.ValidationError as err:
        print(err)
        err = "Given JSON data is InValid"
        return False, err

    message = "Given JSON data is Valid"
    return True, message


def get_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Validate JSON with chained, local dependencies in schema"
    )
    parser.add_argument(
        "base",
        type=str,
        help="Base schema to start the chained dependencies"
    )
    parser.add_argument(
        "-d", "--deps-schema-list",
        nargs="*",
        help="List of inner-chain schema dependencies"
    )
    parser.add_argument(
        "schema",
        type=str,
        help="Schema that has dependencies and used to validate data"
    )
    parser.add_argument(
        "data",
        type=str,
        help="Data to validate against schema")
    return parser


if __name__ == "__main__":
    parser = get_parser()
    args = parser.parse_args()

    with open(args.base, "r") as f:
        base = json.load(f)

    deps_schemas = list()
    for schema_filename in args.deps_schema_list: 
        with open(schema_filename, "r") as f:
            deps_schemas.append(json.load(f))

    with open(args.schema, "r") as f:
        schema = json.load(f)

    with open(args.data, "r") as f:
        data = json.load(f)

    print(validate_schema_with_deps(base, deps_schemas, schema, data))
