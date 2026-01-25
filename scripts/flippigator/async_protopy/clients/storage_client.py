import typing
from assets.protobuf import storage_pb2, flipper_pb2

class FlipperStorageProtoClient:
    def __init__(self, rpc_client):
        self._rpc_client = rpc_client

    async def write_request(self, path: str, data: bytes):
        """
        Write data to a file on Flipper storage.
        """
        request = storage_pb2.WriteRequest()
        request.path = path
        request.file.type = storage_pb2.File.FileType.FILE
        request.file.data = data

        main = flipper_pb2.Main()
        main.storage_write_request.CopyFrom(request)

        return await self._rpc_client.send_and_wait(main)

    async def info_request(self, path: str, wait_for_response: bool = True) -> dict:
        request = storage_pb2.InfoRequest()
        request.path = path

        main = flipper_pb2.Main()
        main.storage_info_request.CopyFrom(request)

        return await self._rpc_client.send_and_wait(main, wait_for_response=wait_for_response)
