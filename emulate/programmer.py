import serial
import argparse
import ast


def parse_instruction_list(instr: str) -> bytes:
    """
    Convert a string like "[0x00, 0x01, 2, 3]" into bytes.
    """
    try:
        data = ast.literal_eval(instr)

        if not isinstance(data, (list, tuple)):
            raise ValueError("Instructions must be a list or tuple")

        return bytes(int(x) & 0xFF for x in data)

    except Exception as e:
        raise argparse.ArgumentTypeError(f"Invalid instruction format: {e}")


def program(port: str, instructions: bytes, baudrate=115200, timeout=1):
    with serial.Serial(port, baudrate, timeout=timeout) as ser:
        # Send preamble
        ser.write(b'\x20' * 8)

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
        help='Instruction list, e.g. "[0x00, 0x01, 2, 3]"'
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