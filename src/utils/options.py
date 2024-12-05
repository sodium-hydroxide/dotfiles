from dataclasses import dataclass
from typing import Literal
from argparse import Namespace

ActionType = Literal["update", "reinstall"]

@dataclass
class CommandOptions:
    """Common command options"""
    action: ActionType
    dry_run: bool
    verbose: bool

def extract_options(args: Namespace) -> CommandOptions:
    """Extract common options from arguments"""
    return CommandOptions(
        action=args.action,
        dry_run=args.dry_run,
        verbose=args.verbose
    )
