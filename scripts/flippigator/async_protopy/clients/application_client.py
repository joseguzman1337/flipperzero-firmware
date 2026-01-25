import flipper_pb2


class ApplicationDataExchangeRequestCommand:
    def __init__(self, data):
        self.data = data


class ApplicationStartRequestCommand:
    def __init__(self, name: str, args: str):
        self.name = name
        self.args = args


class FlipperApplicationProtoClient:
    def __init__(self):
        pass

    async def request(self, command, wait_for_response=True, to_validate=True):
        # Mock request method. In a real scenario, this would send the command to the device.
        pass

    async def events(self):
        # Mock events generator. In a real scenario, this would yield messages from the device
        # received via the underlying protocol (e.g. serial VCP).
        if False:
            yield flipper_pb2.Main()

    async def start_request(self, name: str, args: str, wait_for_response: bool = True):
        """
        Start an application.

        Args:
            name: str
                A name of the application.
            args:
                Arguments to pass to the application.
            wait_for_response: bool
                A flag used to wait for the response data or return after the command is sent (default is True)
        """
        return await self.request(
            ApplicationStartRequestCommand(name=name, args=args),
            wait_for_response=wait_for_response,
            to_validate=True,
        )

    async def data_exchange_send(self, data, wait_for_response=True):
        return await self.request(
            ApplicationDataExchangeRequestCommand(data=data),
            wait_for_response=wait_for_response,
            to_validate=True,
        )

    async def data_exchange_receive(self) -> flipper_pb2.Main:
        """
        Receives data from the Flipper application.
        Waits for an incoming 'app_data_exchange_request' message.
        """
        async for event in self.events():
            if event.HasField("app_data_exchange_request"):
                return event
