# /app/port_proxy.py
import asyncio
import logging
from contextlib import suppress

LISTEN_HOST = "0.0.0.0"

PORT_RANGES = {
    "ml_http": (8001, 8099, 8081),  # (start, end, target_port)
    "ml_aux": (5001, 5099, 5050),
}

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)


async def pipe_stream(reader, writer):
    try:
        while True:
            data = await reader.read(65536)
            if not data:
                break
            writer.write(data)
            await writer.drain()
    finally:
        with suppress(Exception):
            writer.close()
            await writer.wait_closed()


async def handle_client(reader, writer, listen_port: int, target_port: int):
    client_addr = writer.get_extra_info("peername")
    client_id = listen_port % 100  # 8001 -> 1, 8010 -> 10, и т.д.
    target_ip = f"10.0.0.{client_id}"

    logging.info(
        "New connection from %s -> local port %d -> %s:%d (CLIENT_ID=%d)",
        client_addr, listen_port, target_ip, target_port, client_id
    )

    try:
        remote_reader, remote_writer = await asyncio.open_connection(
            target_ip, target_port
        )
    except Exception as e:
        logging.error(
            "Failed to connect to backend %s:%d for port %d: %s",
            target_ip, target_port, listen_port, e
        )
        writer.close()
        await writer.wait_closed()
        return

    # Дуплексный туннель
    task_up = asyncio.create_task(pipe_stream(reader, remote_writer))
    task_down = asyncio.create_task(pipe_stream(remote_reader, writer))

    done, pending = await asyncio.wait(
        {task_up, task_down}, return_when=asyncio.FIRST_COMPLETED
    )
    for t in pending:
        t.cancel()
    logging.info(
        "Connection from %s via port %d to %s:%d closed",
        client_addr, listen_port, target_ip, target_port
    )


async def start_listeners():
    servers = []

    for name, (start_port, end_port, target_port) in PORT_RANGES.items():
        for port in range(start_port, end_port + 1):
            server = await asyncio.start_server(
                lambda r, w, p=port, tp=target_port: handle_client(r, w, p, tp),
                LISTEN_HOST,
                port,
            )
            servers.append(server)
            client_id = port % 100
            logging.info(
                "Listening on %s:%d -> 10.0.0.%d:%d (%s)",
                LISTEN_HOST, port, client_id, target_port, name
            )

    # Ожидаем пока все сервера живы
    await asyncio.gather(*(s.serve_forever() for s in servers))


def main():
    logging.info("Starting Nebula TCP proxy...")
    try:
        asyncio.run(start_listeners())
    except KeyboardInterrupt:
        logging.info("Proxy stopped by KeyboardInterrupt")


if __name__ == "__main__":
    main()
