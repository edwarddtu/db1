#!/usr/bin/env python3

import socket
import serial
import threading
import sys

# Serial port settings
serial_port = '/dev/tty.SLAB_USBtoUART'
baud_rate = 115200

# Network settings
host = '0.0.0.0'  # Listen on all available interfaces
port = 12345      # TCP port to listen on

def handle_client_input(conn, ser):
    try:
        while True:
            data = conn.recv(1024)
            if data:
                #print(f"Received data from TCP client: {data}")
                ser.write(data)
                #print("Data written to serial port.")
            else:
                print("No data received from TCP client or connection closed.")
                break
    except Exception as e:
        print(f"Error in client input handler: {e}")
    finally:
        conn.close()

def listen_serial_output(conn, ser):
    try:
        while True:
            if ser.in_waiting:
                data = ser.read(ser.in_waiting)
                #print(f"Received data from serial port: {data}")
                conn.sendall(data)
                #print("Data sent to TCP client.")
    except Exception as e:
        print(f"Error in serial output handler: {e}")

try:
    ser = serial.Serial(serial_port, baud_rate, timeout=0)
    print(f"Serial port {serial_port} opened at {baud_rate} baud.")

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        s.bind((host, port))
        s.listen()
        print(f"Listening for connections on {host}:{port}...")

        while True:
            conn, addr = s.accept()
            print(f"Connected by {addr}")

            # Start a new thread to handle client input
            threading.Thread(target=handle_client_input, args=(conn, ser)).start()

            # Start a new thread to continuously listen to serial port output
            threading.Thread(target=listen_serial_output, args=(conn, ser)).start()

except serial.SerialException as e:
    print(f"Serial port error: {e}")
    sys.exit(1)
except socket.error as e:
    print(f"Socket error: {e}")
    sys.exit(1)
except KeyboardInterrupt:
    print("Server stopped by user.")
    sys.exit(0)
