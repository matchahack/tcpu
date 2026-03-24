import serial

ser = serial.Serial('/dev/ttyUSB2', 115200, timeout=1)

ser.write(b'\x20' * 8)
resp = ser.read(256)

print(resp)
ser.close()