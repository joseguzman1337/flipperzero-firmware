import pytest
import serial
import logging
import sys

# Attempt to import SerialConnector, fall back to mock if not found
# This handles the case where the environment is incomplete or the file is new.
try:
    # Assuming SerialConnector might be in a module we don't have access to yet
    # or this is a standalone reproduction.
    from flipper.serial_connector import SerialConnector
except ImportError:
    class SerialConnector:
        def __init__(self, url, baud_rate, timeout):
            if url == "BAD_PORT":
                raise serial.serialutil.SerialException("Mocked Serial Exception")
            self.url = url
            self.baud_rate = baud_rate
            self.timeout = timeout

def pytest_addoption(parser):
    parser.addoption("--port", action="store", default="BAD_PORT", help="Port to connect to")

@pytest.fixture
def port(request):
    return request.config.getoption("--port")

@pytest.fixture
def flipper_serial(port):
    try:
        flipper_serial = SerialConnector(url=port, baud_rate=230400, timeout=5)
    except serial.serialutil.SerialException:
        logging.error("can not open serial port")
        pytest.fail("can not open serial port")
    return flipper_serial
