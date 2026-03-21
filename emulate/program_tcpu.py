from dataclasses import dataclass
from typing import List
import serial
import time


@dataclass
class Program:
    name: str
    bytes: List[int]
    description: str


PROGRAMS = {
    "add_1": Program("add_1", [0x20] * 8, "Repeated ADD 1"),
    "add_1_nop": Program("add_1_nop", [0x20] + [0xFF] * 7, "ADD 1 then repeating NOP"),
    "not_add_1_not": Program("not_add_1_not", [0x60, 0x20, 0x60] + [0xFF] * 5, "NOT, ADD 1, NOT"),
}


def send_program_stream(ser: serial.Serial, program: Program) -> None:
    """Send bytes one-by-one and print as they are sent."""
    print(f"\nSending program: {program.name}")
    for i, b in enumerate(program.bytes):
        ser.write(bytes([b]))
        print(f"TX[{i}]: 0x{b:02X}", flush=True)
        time.sleep(0.01)  # optional: helps visualize streaming


def read_response_stream(ser: serial.Serial, timeout: float = 2.0) -> bytes:
    """Read bytes as they arrive and print them in real time."""
    print("RX: ", end="", flush=True)

    start_time = time.time()
    received = bytearray()

    while True:
        if ser.in_waiting > 0:
            b = ser.read(1)
            if b:
                received += b
                print(f"0x{b[0]:02X} ", end="", flush=True)

            # reset timeout timer when data arrives
            start_time = time.time()

        elif time.time() - start_time > timeout:
            break

    print()  # newline after done
    return bytes(received)


def run_program(ser: serial.Serial, program: Program) -> bytes:
    send_program_stream(ser, program)
    return read_response_stream(ser)


def main():
    ser = serial.Serial(
        port="/dev/ttyUSB1",
        baudrate=9600,
        timeout=0  # non-blocking read
    )

    try:
        for key in ["add_1", "add_1_nop", "not_add_1_not"]:
            if key in PROGRAMS:
                response = run_program(ser, PROGRAMS[key])
                print(f"Final response ({key}): {response}\n")
            else:
                print(f"Unknown program: {key}")

    finally:
        ser.close()


if __name__ == "__main__":
    main()