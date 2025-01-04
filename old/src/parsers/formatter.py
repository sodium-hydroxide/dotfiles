from argparse import RawDescriptionHelpFormatter

__all__ = ["CustomHelpFormatter"]


class CustomHelpFormatter(RawDescriptionHelpFormatter):
    """Custom argument help formatter with adjusted indentation.

    Parameters
    ----------
    prog : str
        The program name

    Notes
    -----
    Extends RawDescriptionHelpFormatter to:
        - Set help text position to 40 characters
        - Set maximum width to 80 characters
        - Preserve text formatting in descriptions
    """

    def __init__(self, prog):
        super().__init__(prog, max_help_position=40, width=80)
