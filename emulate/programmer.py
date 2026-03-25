# SPDX-FileCopyrightText: © 2024 Kai Harris
# SPDX-License-Identifier: Apache-2.0

import serial
import argparse
import ast

def parse_instruction_list(instr: str) -> bytes:
    """
    Convert a string like "[0x00, 0x01, ...]" into bytes.
    Must be exactly 8 bytes in hex format.
    """
    try:
        data = ast.literal_eval(instr)
        if not isinstance(data, (list, tuple)):
            raise ValueError("Instructions must be a list or tuple")
        if len(data) != 8:
            raise ValueError("Instruction list must contain exactly 8 bytes")
        result = []
        for x in data:
            if not isinstance(x, int):
                raise ValueError(f"Invalid value {x}: must be an integer in hex format (e.g. 0xaa)")
            if x < 0x00 or x > 0xFF:
                raise ValueError(f"Value {x} out of byte range (0x00–0xFF)")
            result.append(x)
        return bytes(result)
    except Exception as e:
        raise argparse.ArgumentTypeError(f"Invalid instruction format: {e}")

def program(port: str, instructions: bytes, baudrate=115200, timeout=1):
    with serial.Serial(port, baudrate, timeout=timeout) as ser:
        # Send instructions
        ser.write(instructions)
        # Read response
        resp = ser.read(256)
        return resp

def main():
    parser = argparse.ArgumentParser(description="Serial programmer")
    parser.add_argument(
        "-p", "--port",
        required=True,
        help="Serial port (e.g. /dev/ttyUSB2 or COM3)"
    )
    parser.add_argument(
        "-i", "--instructions",
        required=True,
        type=parse_instruction_list,
        help='Instruction list, e.g. "[0x00, 0x01, ...]"'
    )
    parser.add_argument(
        "-b", "--baudrate",
        type=int,
        default=115200,
        help="Baud rate (default: 115200)"
    )
    args = parser.parse_args()
    response = program(args.port, args.instructions, args.baudrate)
    print("Response:", response)

if __name__ == "__main__":
    main()