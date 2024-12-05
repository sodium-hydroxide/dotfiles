
class FSError(Exception):
    """Base exception for filesystem operations"""
    pass

class LinkError(FSError):
    """Exception for symlink operations"""
    pass
