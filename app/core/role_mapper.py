def get_role_from_code(code: str):

    mapping = {

        "st": "student",

        "ad": "admin",

        "do": "advisor"

    }

    return mapping.get(code.lower())