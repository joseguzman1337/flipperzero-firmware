import flipper_pb2

class ApplicationDataExchangeRequestCommand:
    def __init__(self, data):
        self.data = data

class ApplicationLoadFileRequestCommand:
    def __init__(self, path):
        self.path = path

class FlipperApplicationProtoClient:
    def __init__(self):
        pass

    async def request(self, command, wait_for_response=True, to_validate=True):
        pass

    async def events(self):
        if False:
            yield flipper_pb2.Main()

    async def data_exchange_send(self, data, wait_for_response=True):
        return await self.request(
            ApplicationDataExchangeRequestCommand(data=data), wait_for_response=wait_for_response, to_validate=True
        )

    async def data_exchange_receive(self) -> flipper_pb2.Main:
        """
        Receives data from the Flipper application.
        Waits for an incoming 'app_data_exchange_request' message.
        """
        async for event in self.events():
            if event.HasField("app_data_exchange_request"):
                return event

    async def load_file_request(self, path: str, wait_for_response: bool = True):
        """
        Send a request to the application to load a file.

        Args:
            path: str
                Path to the file on Flipper Zero storage (e.g. /ext/app_data/file.txt)
            wait_for_response: bool
                A flag used to wait for the response data or return after the command is sent (default is True)
        """
        return await self.request(
            ApplicationLoadFileRequestCommand(path=path), wait_for_response=wait_for_response, to_validate=True
        )
