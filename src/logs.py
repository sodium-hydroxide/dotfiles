import logging
import sys
from datetime import datetime
from pathlib import Path
from typing import Optional

COLORS = {
    "DEBUG": "\033[36m",  # Cyan
    "INFO": "\033[32m",  # Green
    "WARNING": "\033[33m",  # Yellow
    "ERROR": "\033[31m",  # Red
    "CRITICAL": "\033[41m",  # Red background
    "RESET": "\033[0m",  # Reset color
}

# Create the main logger
logger = logging.getLogger("dotfiles")


class ColorFormatter(logging.Formatter):
    """Custom formatter adding colors to levelname for console output"""

    def format(self, record: logging.LogRecord) -> str:
        if sys.stdout.isatty():
            levelname = record.levelname
            if levelname in COLORS:
                record.levelname = f"{COLORS[levelname]}{levelname}{COLORS['RESET']}"
        return super().format(record)


def get_log_file() -> Path:
    """Get the path for the log file"""
    cache_dir = Path.home() / ".cache" / "dotfiles"
    cache_dir.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d")
    return cache_dir / f"dotfiles_{timestamp}.log"


def setup_logging(verbose: bool = False, log_file: Optional[Path] = None) -> None:
    """Set up logging configuration"""
    logger.setLevel(logging.DEBUG)
    logger.handlers.clear()

    # Console handler with color formatting
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.DEBUG if verbose else logging.INFO)
    console_format = "%(levelname)s: %(message)s"
    console_handler.setFormatter(ColorFormatter(console_format))
    logger.addHandler(console_handler)

    # File handler
    if log_file is None:
        log_file = get_log_file()

    file_handler = logging.FileHandler(log_file)
    file_handler.setLevel(logging.DEBUG)
    file_format = "%(asctime)s - %(levelname)s - %(message)s"
    file_handler.setFormatter(logging.Formatter(file_format))
    logger.addHandler(file_handler)

    logger.debug(f"Logging started. Log file: {log_file}")

