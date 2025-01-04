from typing import Literal

__all__ = ["ConfigAction", "MacosAction", "PackageAction", "ToolchainAction"]

ConfigAction = Literal["update", "cleanup"]
MacosAction = Literal["update", "revert"]
PackageAction = Literal["update", "reinstall"]
ToolchainAction = Literal["update", "reinstall"]
