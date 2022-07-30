import jsonschema


def validate_with_schema_deps(
    base: str,
    schema: str,
    data: str,
    schema_deps_list: list = [],
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
        validator.validate(instance=data)
    except jsonschema.exceptions.ValidationError as err:
        print(err)
        err = "Given JSON data is InValid"
        return False
  
    message = "Given JSON data is Valid"
    return True
