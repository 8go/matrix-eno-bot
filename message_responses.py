#!/usr/bin/env python3

r"""message_responses.py.

0123456789012345678901234567890123456789012345678901234567890123456789012345678
0000000000111111111122222222223333333333444444444455555555556666666666777777777

# message_responses.py

Don't change tabbing, spacing, or formating as the
file is automatically linted and beautified.

"""


from chat_functions import send_text_to_room
import logging

logger = logging.getLogger(__name__)


class Message(object):
    """Process messages."""

    def __init__(self, client, store, config, message_content, room, event):
        """Initialize a new Message.

        Arguments:
        ---------
            client (nio.AsyncClient): nio client used to interact with matrix

            store (Storage): Bot storage

            config (Config): Bot configuration parameters

            message_content (str): The body of the message

            room (nio.rooms.MatrixRoom): The room the event came from

            event (nio.events.room_events.RoomMessageText): The event defining
                the message

        """
        self.client = client
        self.store = store
        self.config = config
        self.message_content = message_content
        self.room = room
        self.event = event

    async def process(self):
        """Process and possibly respond to the message."""
        if self.message_content.lower() == "hello world":
            await self._hello_world()

    async def _hello_world(self):
        """Say hello."""
        text = "Hello, world!"
        await send_text_to_room(self.client, self.room.room_id, text)
