import serial
from flippigator.flippigator import Gator, Navigator
from termcolor import colored
import sys
import asyncio


async def main():
    print(colored("Let's go!", "magenta"))

    gator_serial = serial.Serial(sys.argv[1], timeout=1)

if __name__ == "__main__":
    asyncio.run(main())
