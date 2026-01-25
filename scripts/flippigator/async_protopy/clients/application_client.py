import flipper_pb2

# This file was recreated based on task context as it was missing from the repository.
# It implements a client for interacting with Flipper Zero applications via Protobuf.

class ApplicationDataExchangeRequestCommand:
    def __init__(self, data):
        self.data = data

class FlipperApplicationProtoClient:
    def __init__(self):
        pass

    async def request(self, command, wait_for_response=True, to_validate=True):
        # Mock request method. In a real scenario, this would send the command to the device.
        pass

    async def events(self):
        # Mock events generator. In a real scenario, this would yield messages from the device
        # received via the underlying protocol (e.g. serial VCP).
        # This is a placeholder to allow implementation of data_exchange_receive.
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
