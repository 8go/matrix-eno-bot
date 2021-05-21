#!/usr/bin/env python3

r"""main.py.

0123456789012345678901234567890123456789012345678901234567890123456789012345678
0000000000111111111122222222223333333333444444444455555555556666666666777777777

# main.py

This file implements the following
- create a Matrix client device if necessary
- logs into Matrix as client
- sets up event managers for messages, invites, emoji verification
- enters the event loop

Don't change tabbing, spacing, or formating as the
file is automatically linted and beautified.

"""

import asyncio
import logging
import sys
import traceback
from time import sleep
from nio import (
    AsyncClient,
    AsyncClientConfig,
    RoomMessageText,
    InviteMemberEvent,
    LoginError,
    LocalProtocolError,
    UpdateDeviceError,
    KeyVerificationEvent,
)
from aiohttp import (
    ServerDisconnectedError,
    ClientConnectionError
)
from callbacks import Callbacks
from config import Config
from storage import Storage

logger = logging.getLogger(__name__)


async def main():  # noqa
    """Create bot as Matrix client and enter event loop."""
    # Read config file
    # A different config file path can be specified
    # as the first command line argument
    if len(sys.argv) > 1:
        config_filepath = sys.argv[1]
    else:
        config_filepath = "config.yaml"
    config = Config(config_filepath)

    # Configure the database
    store = Storage(config.database_filepath)

    # Configuration options for the AsyncClient
    client_config = AsyncClientConfig(
        max_limit_exceeded=0,
        max_timeouts=0,
        store_sync_tokens=True,
        encryption_enabled=True,
    )

    # Initialize the matrix client
    client = AsyncClient(
        config.homeserver_url,
        config.user_id,
        device_id=config.device_id,
        store_path=config.store_filepath,
        config=client_config,
    )

    # Set up event callbacks
    callbacks = Callbacks(client, store, config)
    client.add_event_callback(callbacks.message, (RoomMessageText,))
    client.add_event_callback(callbacks.invite, (InviteMemberEvent,))
    client.add_to_device_callback(
        callbacks.to_device_cb, (KeyVerificationEvent,))

    # Keep trying to reconnect on failure (with some time in-between)
    while True:
        try:
            # Try to login with the configured username/password
            try:
                if config.access_token:
                    logger.debug("Using access token from config file to log "
                                 f"in. access_token={config.access_token}")

                    client.restore_login(
                        user_id=config.user_id,
                        device_id=config.device_id,
                        access_token=config.access_token
                    )
                else:
                    logger.debug("Using password from config file to log in.")
                    login_response = await client.login(
                        password=config.user_password,
                        device_name=config.device_name,
                    )

                    # Check if login failed
                    if type(login_response) == LoginError:
                        logger.error("Failed to login: "
                                     f"{login_response.message}")
                        return False
                    logger.info((f"access_token of device {config.device_name}"
                                 f" is: \"{login_response.access_token}\""))
            except LocalProtocolError as e:
                # There's an edge case here where the user hasn't installed
                # the correct C dependencies. In that case, a
                # LocalProtocolError is raised on login.
                logger.fatal(
                    "Failed to login. "
                    "Have you installed the correct dependencies? "
                    "https://github.com/poljar/matrix-nio#installation "
                    "Error: %s", e
                )
                return False

            # Login succeeded!
            logger.debug(f"Logged in successfully as user {config.user_id} "
                         f"with device {config.device_id}.")
            # Sync encryption keys with the server
            # Required for participating in encrypted rooms
            if client.should_upload_keys:
                await client.keys_upload()

            if config.change_device_name:
                content = {"display_name": config.device_name}
                resp = await client.update_device(config.device_id,
                                                  content)
                if isinstance(resp, UpdateDeviceError):
                    logger.debug(f"update_device failed with {resp}")
                else:
                    logger.debug(f"update_device successful with {resp}")

            if config.trust_own_devices:
                await client.sync(timeout=30000, full_state=True)
                # Trust your own devices automatically.
                # Log it so it can be manually checked
                for device_id, olm_device in client.device_store[
                        config.user_id].items():
                    logger.debug("My other devices are: "
                                 f"device_id={device_id}, "
                                 f"olm_device={olm_device}.")
                    logger.info("Setting up trust for my own "
                                f"device {device_id} and session key "
                                f"{olm_device.keys['ed25519']}.")
                    client.verify_device(olm_device)

            await client.sync_forever(timeout=30000, full_state=True)

        except (ClientConnectionError, ServerDisconnectedError):
            logger.warning(
                "Unable to connect to homeserver, retrying in 15s...")

            # Sleep so we don't bombard the server with login requests
            sleep(15)
        finally:
            # Make sure to close the client connection on disconnect
            await client.close()

try:
    asyncio.get_event_loop().run_until_complete(main())
except Exception:
    logger.debug(traceback.format_exc())
    sys.exit(1)
except KeyboardInterrupt:
    logger.debug("Received keyboard interrupt.")
    sys.exit(1)
